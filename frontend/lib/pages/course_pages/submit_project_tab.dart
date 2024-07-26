// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:frontend/pages/course_pages/submit_project_page.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/utils/toasts.dart';
import 'package:getwidget/getwidget.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

class SubmitProject extends StatefulWidget {
  final Course course;
  final bool isPreviewing;
  SubmitProject({
    Key? key,
    required this.course,
    required this.isPreviewing,
  }) : super(key: key);
  @override
  State<SubmitProject> createState() => _SubmitProjectState();
}

class _SubmitProjectState extends State<SubmitProject> {
  CourseService courseService = CourseService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    quillController.document = Document.fromJson(
      jsonDecode(widget.course.projectDescription),
    );
  }

  ScrollController scrollController = ScrollController();
  QuillController quillController = QuillController.basic();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        padding: EdgeInsets.all(5),
        width: double.infinity,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(AppColors.deepBlue),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          onPressed: () async {
            if (widget.isPreviewing) {
              showErrorToast(
                  context, "You can't submit project in preview mode");
              return;
            }
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return SubmitProjectPage(
                    courseId: widget.course.id,
                  );
                },
              ),
            );
          },
          child: const Text(
            "Submit Project",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(
            8, 8, 8, MediaQuery.of(context).size.height * 0.1),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Class projects",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.mediumVertical,
              widget.isPreviewing
                  ? const SizedBox.shrink()
                  : SizedBox(
                      height: 100.0,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                    "https://pollthepeople.app/wp-content/uploads/2022/06/Figma-Design-Flow-Image.png"),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          );
                        },
                      ),
                    ),
              AppSpacing.mediumVertical,
              const Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "Show All",
                  style: TextStyle(
                    color: AppColors.deepBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AppSpacing.mediumVertical,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Project Instructions",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  AppSpacing.mediumVertical,
                  _buildQuillEditor(quillController, scrollController, false),
                  AppSpacing.mediumVertical,
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () {
                        showAllDescription(context);
                      },
                      child: Text(
                        "Show all",
                        style: TextStyle(
                          color: AppColors.deepBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.mediumVertical,
                  Text(
                    "Download Resources",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: courseService
                        .getResourcesStreamByCourse(widget.course.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        List<DocumentSnapshot> resources = snapshot.data!.docs;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${resources.length} resources"),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: resources.length,
                              itemBuilder: (context, index) {
                                DocumentSnapshot resource = resources[index];
                                String resourceId = resource.id;
                                String name = resource["name"];
                                String url = resource["url"];
                                String fileExtension = resource["extension"];
                                return ListTile(
                                  onTap: () {
                                    downloadFile(name, url, fileExtension);
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    Icons.download_for_offline_outlined,
                                    color: AppColors.deepBlue,
                                    size: 28,
                                  ),
                                  title: Text(
                                    name,
                                    style: const TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.deepBlue,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  AppSpacing.mediumVertical,
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future downloadFile(String filename, String url, String fileExtension) async {
    var time = DateTime.now().millisecondsSinceEpoch;
    var path = "/storage/emulated/0/Download/$filename.$fileExtension";
    var file = File(path);
    var res = await get(Uri.parse(url));
    file.writeAsBytes(res.bodyBytes);
  }

  Widget _buildQuillEditor(QuillController controller,
      ScrollController scrollController, bool showAll) {
    return Container(
      width: double.infinity,
      height: showAll
          ? MediaQuery.of(context).size.height * 0.75
          : MediaQuery.of(context).size.height * 0.3,
      decoration: BoxDecoration(
        color: showAll ? AppColors.ghostWhite : AppColors.lighterGrey,
        borderRadius: BorderRadius.circular(5),
        boxShadow: showAll
            ? null
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      padding: const EdgeInsets.all(16),
      child: quill.QuillEditor.basic(
        focusNode: FocusNode(canRequestFocus: false),
        scrollController: scrollController,
        configurations: QuillEditorConfigurations(
          controller: controller,
          scrollPhysics: showAll ? null : const NeverScrollableScrollPhysics(),
          autoFocus: false,
          scrollable: true,
          showCursor: false,
          sharedConfigurations: const QuillSharedConfigurations(
            locale: Locale('en'),
          ),
        ),
      ),
    );
  }

  void showAllDescription(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppColors.ghostWhite,
      builder: (context) {
        return SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
            ),
            child: Column(
              children: [
                AppBar(
                  backgroundColor: AppColors.ghostWhite,
                  leading: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close,
                        size: 20,
                      )),
                  title: const Text(
                    "Project Instruction",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  centerTitle: true,
                ),
                SingleChildScrollView(
                  child: _buildQuillEditor(
                    quillController,
                    scrollController,
                    true,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
