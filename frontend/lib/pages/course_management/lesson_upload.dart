import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_wasm/ffmpeg_wasm.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/pages/course_management/edit_video.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:frontend/services/models/lesson.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/utils/toasts.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:getwidget/components/shimmer/gf_shimmer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:video_player/video_player.dart';

class LessonUpload extends StatefulWidget {
  final String courseId;
  const LessonUpload({
    super.key,
    required this.courseId,
  });

  @override
  State<LessonUpload> createState() => _LessonUploadState();
}

class _LessonUploadState extends State<LessonUpload> {
  //Services
  CourseService courseService = CourseService();

  //Variables
  XFile? pickedVideo;
  UploadTask? uploadTask;
  Duration? videoDuration;

  //Controllers
  final videoTitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    videoTitleController.dispose();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result == null) return;

    final pickedFile = result.files.first;
    final file = XFile(pickedFile.path!);

    XFile video = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => VideoEditor(file: file),
      ),
    );

    final videoPlayerController = VideoPlayerController.file(File(video.path));
    await videoPlayerController.initialize();
    videoDuration = videoPlayerController.value.duration;

    setState(() {
      pickedVideo = video;
    });
    await uploadVideo();
  }

  Future<XFile?> getThumbnail(String videoUrl) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 50,
        quality: 75,
      );

      if (thumbnailPath != null) {
        return thumbnailPath;
      }
    } catch (e) {
      print('Error generating thumbnail: $e');
    }
    return null;
  }

  Future<void> uploadVideo() async {
    // upload video to firebase
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final path = 'video_lessons/$timestamp';
    final file = File(pickedVideo!.path);

    final ref = FirebaseStorage.instance.ref().child(path);
    setState(() {
      uploadTask = ref.putFile(file);
    });
    final snapshot = await uploadTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    setState(() {
      uploadTask = null;
    });

    var data = {
      "duration": formatDuration(videoDuration!),
      "index": 1,
      "link": urlDownload,
      "title": pickedVideo!.name,
      "timestamp": timestamp,
    };

    await courseService.createLesson(widget.courseId, data);
  }

  Future<void> deleteLesson(
      String courseId, String lessonId, String videoPath) async {
    await courseService.deleteLesson(courseId, lessonId);
    final ref = FirebaseStorage.instance.ref().child(videoPath);
    await ref.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Upload lessons",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Video lessons",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                ),
                AppSpacing.mediumVertical,
                const Text(
                  "• Include a standalone introduction video that explains what the class is about.",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppSpacing.mediumVertical,
                const Text(
                  "• Limit self-promotion to first and last video lessons.",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppSpacing.mediumVertical,
                Container(
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.lighterGrey,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                          bottom: 40,
                        ),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: courseService
                                .getLessonStreamByCourse(widget.courseId),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                List<DocumentSnapshot> lessons =
                                    snapshot.data!.docs;
                                if (lessons.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      "Your class need videos",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                      ),
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  itemCount: lessons.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot document = lessons[index];
                                    String lessonId = document.id;
                                    Map<String, dynamic> data = lessons[index]
                                        .data() as Map<String, dynamic>;
                                    String lessonTitle = data['title'];
                                    String duration = data['duration'];
                                    String timestamp = data['timestamp'];

                                    String videoUrl = data['link'];

                                    videoTitleController.text = lessonTitle;
                                    return FutureBuilder(
                                      future: getThumbnail(videoUrl),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return GFShimmer(
                                            child: Column(
                                              children: [
                                                emptyBlock(context),
                                                AppSpacing.mediumVertical,
                                              ],
                                            ),
                                          );
                                        }
                                        log(snapshot.data.toString());
                                        return Column(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 10),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: AppColors.lightGrey,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: ListTile(
                                                trailing: PopupMenuButton(
                                                  offset: const Offset(10, -20),
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  constraints:
                                                      const BoxConstraints
                                                          .expand(
                                                    width: 50,
                                                    height: 100,
                                                  ),
                                                  icon: const Icon(
                                                    Icons.more_horiz_outlined,
                                                  ),
                                                  color: AppColors.deepBlue,
                                                  elevation: 0,
                                                  itemBuilder: (context) => [
                                                    PopupMenuItem(
                                                      child: const Icon(
                                                        Icons.edit_outlined,
                                                        color: Colors.white,
                                                      ),
                                                      onTap: () async {},
                                                    ),
                                                    PopupMenuItem(
                                                      child: const Icon(
                                                        Icons.delete_forever,
                                                        color: Colors.red,
                                                      ),
                                                      onTap: () async {
                                                        final videoPath =
                                                            'video_lessons/$timestamp';
                                                        await deleteLesson(
                                                          widget.courseId,
                                                          lessonId,
                                                          videoPath,
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                leading: snapshot.hasData
                                                    ? Image.file(
                                                        File(snapshot
                                                            .data!.path),
                                                        fit: BoxFit.cover,
                                                        width: 50,
                                                        height: 50,
                                                      )
                                                    : const Icon(
                                                        Icons.video_library,
                                                        color:
                                                            AppColors.deepBlue,
                                                      ),
                                                title: TextField(
                                                  readOnly: true,
                                                  decoration:
                                                      InputDecoration.collapsed(
                                                    hintText: lessonTitle,
                                                  ),
                                                  maxLines: 2,
                                                  style: const TextStyle(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                subtitle: Text(duration),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              } else {
                                return const Center(
                                  child: Text(
                                    "Your class need videos",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      buildProgress(),
                      const Divider(),
                      GestureDetector(
                        onTap: () async {
                          _pickVideo();
                        },
                        child: const Icon(
                          Icons.add_circle_outline_outlined,
                          size: 30,
                        ),
                      ),
                      const Text(
                        "Upload Videos",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProgress() => StreamBuilder(
        stream: uploadTask?.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData && uploadTask != null) {
            final data = snapshot.data!;
            double progress = data.bytesTransferred / data.totalBytes;
            return SizedBox(
              height: 50,
              child: Column(
                children: [
                  Center(
                    child: Text(
                      "${(100 * progress).roundToDouble()}%",
                    ),
                  ),
                  LinearPercentIndicator(
                    animateFromLastPercent: true,
                    percent: progress,
                    barRadius: const Radius.circular(10),
                    progressColor: AppColors.cream,
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      );

  Widget emptyBlock(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 46,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: 8,
                  color: Colors.white,
                ),
                const SizedBox(height: 6),
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 8,
                  color: Colors.white,
                ),
                const SizedBox(height: 6),
                Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: 8,
                  color: Colors.white,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
