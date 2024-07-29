import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:async_button/async_button.dart';
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
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
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
  final TextEditingController priceController = TextEditingController();

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final btnStateController = AsyncBtnStatesController();

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

  @override
  void dispose() {
    // TODO: implement dispose
    resourceNameController.dispose();
    focusNode.dispose();
    super.dispose();
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
        "extension": pickedFile!.extension,
      };
      log(resource.toString());
      await courseService.addResourceToCourse(myCourse.id, resource);
    }

    setState(() {
      uploadTask = null;
    });
  }

  Future downloadFile(String filename, String url) async {
    var path = "";
    if (Platform.isAndroid) {
      path = "/storage/emulated/0/Download/$filename";
    } else if (Platform.isIOS) {
      var downloadDir = await getApplicationDocumentsDirectory();
      path = "${downloadDir.path}/$filename";
    }

    if (path.isEmpty) {
      log("Platform not supported");
      return;
    }

    var file = File(path);

    var res = await get(Uri.parse(url));
    file.writeAsBytes(res.bodyBytes);
    log("Downloaded file to $path");
    await openFile(file);
  }

  Future openFile(File file) async {
    try {
      log("Opening file: ${file.path}");
      await OpenFile.open(file.path);
    } catch (e) {
      log("Error opening file: $e");
    }
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
        backgroundColor: AppColors.ghostWhite,
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
                        text: "Add a price",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: " (minimum: 100.000đ)",
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
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      validator: (value) {
                        if (value != null) {
                          if (value.isEmpty) {
                            return "Please enter a price";
                          }
                          if (int.parse(value) < 100000) {
                            return "Price must be at least 100,000 VND";
                          }
                        }
                        return null;
                      },
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      cursorColor: AppColors.blue,
                      decoration: const InputDecoration(
                        labelText: 'Course Price (vnd)',
                        labelStyle: TextStyle(
                          color: AppColors.lightGrey,
                          fontSize: 16,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.blue,
                            width: 2,
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.blue,
                          ),
                        ),
                      ),
                    ),
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
                  AppSpacing.largeVertical,
                  SizedBox(
                    width: double.infinity,
                    child: AsyncOutlinedBtn(
                      loadingStyle: AsyncBtnStateStyle(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cream,
                        ),
                        widget: const Center(
                          child: MyLoading(
                            width: 20,
                            height: 20,
                            color: AppColors.deepBlue,
                          ),
                        ),
                      ),
                      successStyle: AsyncBtnStateStyle(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cream,
                        ),
                        widget: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check),
                            SizedBox(width: 4),
                            Text('Success!')
                          ],
                        ),
                      ),
                      style: AppStyles.primaryButtonStyle,
                      asyncBtnStatesController: btnStateController,
                      onPressed: () async {
                        try {
                          // Await your api call here
                          if (_formKey.currentState!.validate()) {
                            btnStateController.update(AsyncBtnState.loading);

                            await courseService.updateCourse(
                              widget.courseId,
                              {"price": int.parse(priceController.text)},
                            );
                            await courseService.requestCourse(widget.courseId);
                            btnStateController.update(AsyncBtnState.success);
                            await Future.delayed(
                                const Duration(milliseconds: 500));
                            Navigator.pop(context);
                            Navigator.pop(context);
                          } else {}
                        } catch (e) {
                          btnStateController.update(AsyncBtnState.failure);
                        }
                      },
                      child: const Text(
                        "Publish Course",
                        style: TextStyle(fontSize: 16),
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
