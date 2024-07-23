import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/images.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/utils/toasts.dart';
import 'package:frontend/widgets/course_card.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class PublishCourse extends StatefulWidget {
  final String courseId;
  final int lessonNums;
  const PublishCourse({
    super.key,
    required this.courseId,
    required this.lessonNums,
  });

  @override
  State<PublishCourse> createState() => _PublishCourseState();
}

class _PublishCourseState extends State<PublishCourse> {
  CourseService courseService = CourseService();
  UserService userService = UserService();

  late Course myCourse;
  late Future<void> _future;
  String courseThumbnail = "";
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  List<String> uploadedResources = [];
  String? editingResourceId;
  final resourceNameController = TextEditingController();
  final storageRef = FirebaseStorage.instance.ref();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _future = _initCourseDetailPage();
    focusNode.addListener(_onFocusChange);
  }

  Future<void> _initCourseDetailPage() async {
    await _fetchCourseDetails();
  }

  void _onFocusChange() {
    if (!focusNode.hasFocus && editingResourceId != null) {
      courseService.updateResourceInCourse(
        widget.courseId,
        editingResourceId!,
        {'name': resourceNameController.text},
      );
      setState(() {
        editingResourceId = null;
      });
    }
  }

  Future<void> _fetchCourseDetails() async {
    try {
      myCourse = await courseService.getCourseById(widget.courseId);
      courseThumbnail = myCourse.thumbnail;
    } catch (e) {
      log("Error getting course $e");
    }
  }

  void selectImageFromGallery() async {
    Uint8List selectedImage = await pickImage(ImageSource.gallery);
    updateCourseThumbnail(selectedImage);
  }

  void updateCourseThumbnail(Uint8List selectedImage) async {
    final imageRef =
        storageRef.child('course_thumbnail/thumbnail_${widget.courseId}');
    await imageRef.putData(selectedImage);
    var photoUrl = (await imageRef.getDownloadURL()).toString();
    setState(() {
      courseThumbnail = photoUrl;
    });
    var imageData = {
      "thumbnail": courseThumbnail,
    };

    try {
      await courseService.updateCourse(
        widget.courseId,
        imageData,
      );
    } catch (e) {
      showErrorToast(context, "Error adding image");
    }
  }

  Future<void> deleteResources(String resourceId, String timestamp) async {
    await courseService.deleteResourceFromCourse(myCourse.id, resourceId);
    final resourceRef = storageRef.child("course_resources/$timestamp");
    await resourceRef.delete();
  }

  Future selectResources() async {
    final result = await FilePicker.platform.pickFiles();

    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });

    await uploadResources();
  }

  Future uploadResources() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final path = "course_resources/$timestamp";
    final file = File(pickedFile!.path!);
    final ref = FirebaseStorage.instance.ref().child(path);
    setState(() {
      uploadTask = ref.putFile(file);
    });
    final snapshot = await uploadTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    if (pickedFile != null) {
      var resource = {
        "name": pickedFile!.name,
        "url": urlDownload,
        "timestamp": timestamp,
      };
      log(resource.toString());
      await courseService.addResourceToCourse(myCourse.id, resource);
    }

    setState(() {
      uploadTask = null;
    });
  }

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
        stream: uploadTask?.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData && uploadTask != null) {
            final data = snapshot.data!;
            double progress = data.bytesTransferred / data.totalBytes;
            return Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              height: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LinearPercentIndicator(
                    animateFromLastPercent: true,
                    percent: progress,
                    barRadius: const Radius.circular(10),
                    progressColor: AppColors.cream,
                    backgroundColor: Colors.grey[200],
                    lineHeight: 12,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.ghostWhite,
      appBar: AppBar(
        surfaceTintColor: AppColors.ghostWhite,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close),
        ),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: MyLoading(
                width: 30,
                height: 30,
                color: AppColors.deepBlue,
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      selectImageFromGallery();
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_outlined, color: AppColors.deepBlue),
                        Text(
                          "Change thubmnail",
                          style: TextStyle(
                            color: AppColors.deepBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.mediumVertical,
                  CourseCard(
                    thumbnail: courseThumbnail.isNotEmpty
                        ? courseThumbnail
                        : "https://i.ibb.co/tZxYspW/default-avatar.png",
                    instructor:
                        FirebaseAuth.instance.currentUser!.displayName ??
                            "Mindify Member",
                    specialization: "Mindify Instructor",
                    courseName: myCourse.title,
                    time: myCourse.duration,
                    numberOfLesson: widget.lessonNums,
                    avatar: Image.network(userService.getPhotoUrl()),
                    onSavePressed: () {},
                    isSaved: false,
                  ),
                  AppSpacing.largeVertical,
                  Align(
                    alignment: Alignment.topLeft,
                    child: RichText(
                      text: const TextSpan(
                        text: "Additional Resources",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: " (docs, pdf,...)",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AppSpacing.mediumVertical,
                  StreamBuilder(
                    stream:
                        courseService.getResourcesStreamByCourse(myCourse.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<DocumentSnapshot> resources = snapshot.data!.docs;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: resources.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot resource = resources[index];
                            String resourceId = resource.id;
                            String name = resource["name"];
                            String url = resource["url"];
                            String timestamp = resource["timestamp"];

                            return ListTile(
                              leading: const Icon(
                                Icons.file_copy_outlined,
                                color: AppColors.deepBlue,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      if (editingResourceId == null) {
                                        setState(() {
                                          editingResourceId = resourceId;
                                          resourceNameController.text = name;
                                          focusNode.requestFocus();
                                        });
                                      } else {
                                        courseService.updateResourceInCourse(
                                          widget.courseId,
                                          resourceId,
                                          {'name': name},
                                        );
                                        setState(() {
                                          editingResourceId = null;
                                        });
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.edit,
                                      color: AppColors.deepBlue,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      await deleteResources(
                                        resourceId,
                                        timestamp,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              title: editingResourceId == resourceId
                                  ? TextField(
                                      onSubmitted: (value) {
                                        courseService.updateResourceInCourse(
                                          widget.courseId,
                                          resourceId,
                                          {'name': value},
                                        );
                                        setState(() {
                                          editingResourceId = null;
                                        });
                                      },
                                      textInputAction: TextInputAction.done,
                                      controller: resourceNameController,
                                      focusNode: focusNode,
                                      decoration:
                                          const InputDecoration.collapsed(
                                        hintText: "",
                                        hintStyle: TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.deepBlue,
                                        ),
                                      ),
                                      maxLines: 2,
                                      style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  : Text(
                                      name,
                                      style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.deepBlue,
                                      ),
                                    ),
                            );
                          },
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                  AppSpacing.mediumVertical,
                  buildProgress(),
                  AppSpacing.mediumVertical,
                  ElevatedButton(
                    onPressed: () async {
                      await selectResources();
                    },
                    style: AppStyles.secondaryButtonStyle,
                    child: const Icon(
                      Icons.upload_file,
                    ),
                  ),
                  AppSpacing.extraLargeVertical,
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      style: AppStyles.primaryButtonStyle,
                      onPressed: () async {
                        await courseService.requestCourse(widget.courseId);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Publish Course",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
