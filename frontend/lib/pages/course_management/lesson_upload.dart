import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:frontend/services/models/lesson.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:file_picker/file_picker.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

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
  PlatformFile? pickedVideo;
  UploadTask? uploadTask;

  Future<void> selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result == null) return;

    setState(() {
      pickedVideo = result.files.first;
    });
  }

  Future<void> uploadVideo() async {
    // upload video to firebase
    final path = 'video_lessons/${pickedVideo!.name}';
    final file = File(pickedVideo!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    setState(() {
      uploadTask = ref.putFile(file);
    });
    final snapshot = await uploadTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    log("url download $urlDownload");
    setState(() {
      uploadTask = null;
    });

    var data = {
      "duration": "1:34",
      "index": 1,
      "link": urlDownload,
      "title": pickedVideo!.name,
    };

    await courseService.createLesson(widget.courseId, data);
  }

  @override
  void initState() {
    super.initState();
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
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.lightGrey,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: ListTile(
                                        trailing: const Icon(Icons.more_horiz),
                                        leading: const Icon(
                                          Icons.video_library,
                                          color: AppColors.deepBlue,
                                        ),
                                        title: Text(
                                          lessonTitle,
                                          maxLines: 2,
                                          style: const TextStyle(
                                            overflow: TextOverflow.ellipsis,
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
                          await selectFile();
                          await uploadVideo();
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
          if (snapshot.hasData) {
            final data = snapshot.data!;
            double progress = data.bytesTransferred / data.totalBytes;
            return SizedBox(
              height: 50,
              child: Column(
                children: [
                  Center(
                    child: Text(
                      "${(100 * progress).roundToDouble()}%",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  LinearPercentIndicator(
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
}
