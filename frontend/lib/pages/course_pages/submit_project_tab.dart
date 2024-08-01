// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:frontend/pages/course_pages/show_all_projects.dart';
import 'package:frontend/pages/course_pages/submit_project_page.dart';
import 'package:frontend/pages/course_pages/view_my_project.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:frontend/services/functions/ProjectService.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/utils/toasts.dart';
import 'package:getwidget/getwidget.dart';
import 'package:http/http.dart';
import 'package:open_file_plus/open_file_plus.dart';
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
  ProjectService projectService = ProjectService();
  bool hasSubmitted = false;
  DocumentSnapshot? Myproject;
  String? MyProjectId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    quillController.document = Document.fromJson(
      jsonDecode(widget.course.projectDescription),
    );
    checkSubmissionStatus();
    getUserProject();
  }

  void checkSubmissionStatus() async {
    bool submitted = await projectService.hasSubmittedProject(
      widget.course.id,
      FirebaseAuth.instance.currentUser!.uid,
    );
    setState(() {
      hasSubmitted = submitted;
    });
  }

  Future<void> getUserProject() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String courseId = widget.course.id;
    DocumentSnapshot? project =
        await projectService.getProjectId(courseId, uid);

    if (project != null) {
      setState(() {
        Myproject = project;
        MyProjectId = project.id;
      });
    }
  }

  ScrollController scrollController = ScrollController();
  QuillController quillController = QuillController.basic();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        padding: EdgeInsets.all(5),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasSubmitted)
              TextButton(
                onPressed: () {
                  // Navigate to the user's project page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewMyProject(
                        courseId: widget.course.id,
                        project: Myproject!,
                        projectId: MyProjectId!,
                        teacherId: widget.course.instructorId,
                      ),
                    ),
                  );
                },
                child: Text(
                  "View My Project",
                  style: TextStyle(
                    color: AppColors.deepBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            SizedBox(
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

                  if (widget.course.instructorId ==
                      FirebaseAuth.instance.currentUser!.uid) {
                    showErrorToast(
                        context, "You can't submit project of your own class");
                    return;
                  }

                  if (hasSubmitted) {
                    if (Myproject == null) {
                      showErrorToast(
                        context,
                        "Error removing project, please try again later",
                      );
                      return;
                    }

                    await projectService.removeProject(
                      widget.course.id,
                      Myproject!.id,
                    );

                    final folderRef = Myproject!["folderRef"];
                    final storageRef = FirebaseStorage.instance.ref();
                    final projectFolderRef = storageRef.child(
                        "course_projects/${widget.course.id}/$folderRef");

                    // Function to delete all items in a folder
                    Future<void> deleteFolderContents(
                        Reference folderRef) async {
                      ListResult result = await folderRef.listAll();
                      for (var item in result.items) {
                        await item.delete();
                        log('Deleted file: ${item.fullPath}');
                      }
                      for (var prefix in result.prefixes) {
                        await deleteFolderContents(prefix);
                      }
                    }

                    await deleteFolderContents(projectFolderRef);

                    log('Deleted project folder and all its contents: ${projectFolderRef.fullPath}');
                    checkSubmissionStatus();
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
                  if (result != null) {
                    checkSubmissionStatus();
                    getUserProject();
                  }
                },
                child: Text(
                  hasSubmitted ? "Remove project" : "Submit Project",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
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
                  : StreamBuilder<QuerySnapshot>(
                      stream: projectService.getProjectStream(widget.course.id),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                                "This class don't have submitted project yet"),
                          );
                        }
                        List<DocumentSnapshot> projects = snapshot.data!.docs;
                        return SizedBox(
                          height: 100.0,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: projects.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot project = projects[index];
                              String projectCoverImage = project["coverImage"];
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                width: MediaQuery.of(context).size.width * 0.5,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(projectCoverImage),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              );
                            },
                          ),
                        );
                      }),
              AppSpacing.mediumVertical,
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return ShowAllProjects(
                          course: widget.course,
                        );
                      },
                    ),
                  );
                },
                child: const Align(
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
    var path = "";
    if (Platform.isAndroid) {
      path = "/storage/emulated/0/Download/$filename.$fileExtension";
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
