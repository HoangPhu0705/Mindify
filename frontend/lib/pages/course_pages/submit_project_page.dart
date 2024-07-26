import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/functions/ProjectService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/images.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
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
  Projectservice projectservice = Projectservice();

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

  void selectCoverImage() async {
    XFile? image = await pickImage(ImageSource.gallery);
    if (image != null) {
      setState(() {
        coverImage = image.path;
      });
    }
  }

  Future<void> uploadImages(List<XFile> files, String path) async {
    for (var file in files) {
      final ref = FirebaseStorage.instance.ref().child('$path/${file.name}');
      try {
        await ref.putFile(File(file.path));
        final urlDownload = await ref.getDownloadURL();
        print('Image uploaded: $urlDownload');
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  Future selectFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );
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
            children: selectedImages!.map((image) {
              return Image.file(
                File(image.path),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              );
            }).toList(),
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

  void submitProject() {
    if (_formKey.currentState!.validate()) {
      // Perform the submit action here
      if (coverImage != null) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
                    onPressed: submitProject,
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
