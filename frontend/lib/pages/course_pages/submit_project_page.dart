import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/functions/ProjectService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/images.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class SubmitProjectPage extends StatefulWidget {
  final String courseId;

  const SubmitProjectPage({
    super.key,
    required this.courseId,
  });

  @override
  State<SubmitProjectPage> createState() => _SubmitProjectPageState();
}

class _SubmitProjectPageState extends State<SubmitProjectPage> {
  final _formKey = GlobalKey<FormState>();
  UploadTask? uploadTask;
  FocusNode projectTitleNode = FocusNode();
  FocusNode projectDescriptionNode = FocusNode();
  String? coverImage;
  List<PlatformFile>? pickedFile;
  List<XFile>? selectedImages;
  Map<String, dynamic> projectContent = {};
  final projectDescriptionController = TextEditingController();
  final projectTitleController = TextEditingController();
  ProjectService projectservice = ProjectService();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    projectTitleNode.dispose();
    projectDescriptionNode.dispose();
    super.dispose();
  }

  void selectImageFromGallery() async {
    List<XFile>? images = await pickMultipleImage(ImageSource.gallery);
    if (images != null) {
      setState(() {
        selectedImages = images;
      });
    }
  }

  Future<List<XFile>?> pickMultipleImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();
    return await _imagePicker.pickMultiImage();
  }

  Future<XFile?> pickSingleImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();
    return await _imagePicker.pickImage(source: source);
  }

  void selectCoverImage() async {
    XFile? image = await pickSingleImage(ImageSource.gallery);
    if (image != null) {
      setState(() {
        coverImage = image.path;
      });
    }
  }

  Future<String?> uploadFileToStorage(File file, String path) async {
    final ref = FirebaseStorage.instance.ref().child(path);
    try {
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  Future<void> selectFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;
    setState(() {
      pickedFile = result.files;
    });
  }

  Widget buildImagePreview() {
    return selectedImages == null
        ? Container()
        : Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedImages!.map(
              (image) {
                return Image.file(
                  File(image.path),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                );
              },
            ).toList(),
          );
  }

  Widget buildCoverImagePreview() {
    return coverImage == null
        ? Container()
        : Image.file(
            File(coverImage!),
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          );
  }

  Future<void> submitProject() async {
    if (_formKey.currentState!.validate() &&
        coverImage != null &&
        (pickedFile != null || selectedImages != null)) {
      await uploadAll();
      projectContent['title'] = projectTitleController.text;
      projectContent['description'] = projectDescriptionController.text;
      projectContent['userId'] = FirebaseAuth.instance.currentUser!.uid;

      await projectservice.submitProject(widget.courseId, projectContent);

      Navigator.pop(context, true);
    } else {
      log("Not enough data to submit project");
    }
  }

  Future<void> uploadAll() async {
    final folderRef = DateTime.now().millisecondsSinceEpoch.toString();
    final path = 'course_projects/${widget.courseId}/$folderRef';
    projectContent['folderRef'] = folderRef;

    // Upload cover image
    if (coverImage != null) {
      final coverImageUrl =
          await uploadFileToStorage(File(coverImage!), '$path/cover_image.jpg');
      if (coverImageUrl != null) {
        projectContent['coverImage'] = coverImageUrl;
      }
    }

    // Upload content images
    if (selectedImages != null) {
      List<String> imageUrls = [];
      for (var image in selectedImages!) {
        final imageUrl = await uploadFileToStorage(
            File(image.path), '$path/content_images/${image.name}');
        if (imageUrl != null) {
          imageUrls.add(imageUrl);
        }
      }
      projectContent['contentImages'] = imageUrls;
    }

    // Upload other files
    if (pickedFile != null) {
      List<Map<String, String>> fileDetails = [];
      for (var file in pickedFile!) {
        final fileUrl = await uploadFileToStorage(
            File(file.path!), '$path/files/${file.name}');
        if (fileUrl != null) {
          // Get file type from the file extension
          final fileType = getFileType(file.name);
          fileDetails.add({
            'name': file.name,
            'url': fileUrl,
            'type': fileType,
          });
        }
      }
      projectContent['files'] = fileDetails;
    }

    setState(() {});
  }

  String getFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 'image';
      case 'pdf':
        return 'pdf';
      case 'doc':
      case 'docx':
        return 'document';
      case 'txt':
        return 'text';
      case 'mp4':
        return 'video';
      default:
        return 'unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      useDefaultLoading: false,
      overlayWidgetBuilder: (_) {
        //ignored progress for the moment
        return const Center(
            child: MyLoading(
          width: 30,
          height: 30,
          color: AppColors.deepBlue,
        ));
      },
      child: Scaffold(
        backgroundColor: AppColors.ghostWhite,
        appBar: AppBar(
          surfaceTintColor: AppColors.ghostWhite,
          backgroundColor: AppColors.ghostWhite,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: AppStyles.primaryButtonStyle,
                      onPressed: () async {
                        context.loaderOverlay.show();
                        await submitProject();
                        context.loaderOverlay.hide();
                      },
                      child: const Text(
                        "Submit Project",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                  AppSpacing.mediumVertical,
                  const Text(
                    "Cover Image",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  AppSpacing.smallVertical,
                  const Text(
                    "Choose a photo that represents your project.",
                    style: TextStyle(fontSize: 14),
                  ),
                  AppSpacing.mediumVertical,
                  ElevatedButton(
                    onPressed: selectCoverImage,
                    style: AppStyles.secondaryButtonStyle,
                    child: const Text(
                      "Upload Cover Image",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                  AppSpacing.mediumVertical,
                  buildCoverImagePreview(),
                  AppSpacing.largeVertical,
                  const Text(
                    "Project Title",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  AppSpacing.smallVertical,
                  TextFormField(
                    controller: projectTitleController,
                    cursorColor: AppColors.blue,
                    onTapOutside: (event) {
                      log("Tapped outside");
                      FocusScope.of(context).unfocus();
                    },
                    focusNode: projectTitleNode,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.lightGrey,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a project title';
                      }
                      return null;
                    },
                  ),
                  AppSpacing.largeVertical,
                  const Text(
                    "Project Description",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  AppSpacing.smallVertical,
                  TextFormField(
                    controller: projectDescriptionController,
                    maxLines: 8,
                    cursorColor: AppColors.blue,
                    onTapOutside: (event) {
                      FocusScope.of(context).unfocus();
                    },
                    focusNode: projectDescriptionNode,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.lightGrey,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a project description';
                      }
                      return null;
                    },
                  ),
                  AppSpacing.largeVertical,
                  const Text(
                    "Project Contents",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  AppSpacing.smallVertical,
                  buildImagePreview(),
                  AppSpacing.smallVertical,
                  pickedFile != null
                      ? ListView.builder(
                          itemCount: pickedFile!.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                openFile(pickedFile![index]);
                              },
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                pickedFile![index].name,
                                style: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.deepBlue,
                                ),
                              ),
                            );
                          })
                      : const SizedBox.shrink(),
                  Row(
                    children: [
                      buildProjectContent(
                        Icons.image_outlined,
                        "Image",
                        selectImageFromGallery,
                      ),
                      AppSpacing.largeHorizontal,
                      buildProjectContent(
                        Icons.file_upload_outlined,
                        "File",
                        selectFiles,
                      ),
                      AppSpacing.largeHorizontal,
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProjectContent(IconData icon, String title, Function() onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
          ),
          AppSpacing.smallVertical,
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
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

  static const TextStyle _labelStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  void openFile(PlatformFile file) {
    OpenFile.open(file.path);
  }
}
