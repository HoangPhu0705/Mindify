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
  String? editingLessonId;
  int lessonIndex = 0;
  int totalDuration = 0;
  //Controllers
  final videoTitleController = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    videoTitleController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _pickVideo() async {
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

      return thumbnailPath;
    } catch (e) {
      log('Error generating thumbnail: $e');
    }
    return null;
  }

  Future<void> uploadVideo(int index) async {
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
      "index": index,
      "link": urlDownload,
      "title": pickedVideo!.name,
      "timestamp": timestamp,
    };

    await courseService.createLesson(widget.courseId, data);
  }

  Future<void> deleteLesson(
      String courseId, String lessonId, String videoPath) async {
    try {
      await courseService.deleteLesson(courseId, lessonId);

      final ref = FirebaseStorage.instance.ref().child(videoPath);
      await ref.delete();

      final snapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .orderBy('index')
          .get();

      int deletedIndex = snapshot.docs.indexWhere((doc) => doc.id == lessonId);

      for (int i = deletedIndex; i < snapshot.docs.length; i++) {
        await FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .collection('lessons')
            .doc(snapshot.docs[i].id)
            .update({'index': i});
      }

      log("Lesson deleted successfully");
    } catch (e) {
      log("Error: $e");
      throw Exception("Error deleting lesson");
    }
  }

  void _onFocusChange() {
    if (!focusNode.hasFocus && editingLessonId != null) {
      courseService.updateLesson(
        widget.courseId,
        editingLessonId!,
        {'title': videoTitleController.text},
      );
      setState(() {
        editingLessonId = null;
      });
    }
  }

  Future<void> updateLessonIndex(String lessonId, int newIndex) async {
    // Update the index field in Firestore
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('lessons')
        .doc(lessonId)
        .update({'index': newIndex});
  }

  void reorderData(List<DocumentSnapshot> list, int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final DocumentSnapshot item = list.removeAt(oldIndex);
      list.insert(newIndex, item);

      for (int i = 0; i < list.length; i++) {
        updateLessonIndex(list[i].id, i);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () async {
            dynamic totalDuration = await courseService.getCombinedDuration(
              widget.courseId,
            );

            await courseService.updateCourse(
              widget.courseId,
              {'totalDuration': totalDuration["totalSeconds"]},
            );
            Navigator.pop(context);
          },
        ),
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
                  "• We recommend record in 16:9 ratio for the best viewing experience.",
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
                                return ReorderableListView.builder(
                                  onReorder: (oldIndex, newIndex) {
                                    reorderData(lessons, oldIndex, newIndex);
                                  },
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
                                    lessonIndex = lessons.length;

                                    return Container(
                                      key: ValueKey(lessonId),
                                      margin: const EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.lightGrey,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 5,
                                        ),
                                        trailing: PopupMenuButton(
                                          offset: const Offset(10, -20),
                                          padding: const EdgeInsets.all(5),
                                          constraints:
                                              const BoxConstraints.expand(
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
                                              onTap: () {
                                                setState(() {
                                                  editingLessonId = lessonId;
                                                  videoTitleController.text =
                                                      lessonTitle;
                                                  focusNode.requestFocus();
                                                });
                                              },
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
                                        leading: const Icon(
                                          Icons.video_library_outlined,
                                          size: 30,
                                        ),
                                        title: editingLessonId == lessonId
                                            ? TextField(
                                                onSubmitted: (value) {
                                                  courseService.updateLesson(
                                                    widget.courseId,
                                                    lessonId,
                                                    {'title': value},
                                                  );
                                                  setState(() {
                                                    editingLessonId = null;
                                                  });
                                                },
                                                textInputAction:
                                                    TextInputAction.done,
                                                controller:
                                                    videoTitleController,
                                                focusNode: focusNode,
                                                decoration:
                                                    const InputDecoration
                                                        .collapsed(
                                                  hintText: "Video title",
                                                  hintStyle: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                maxLines: 2,
                                                style: const TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              )
                                            : Text(
                                                lessonTitle,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                              ),
                                        subtitle: Text(duration),
                                      ),
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
                          await _pickVideo();
                          await uploadVideo(lessonIndex);
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
