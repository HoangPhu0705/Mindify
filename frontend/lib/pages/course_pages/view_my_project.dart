// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/services/functions/ProjectService.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:open_file_plus/open_file_plus.dart';

import 'package:path_provider/path_provider.dart';
import 'package:widget_zoom/widget_zoom.dart';

class ViewMyProject extends StatefulWidget {
  final String courseId;
  final String projectId;
  final String teacherId;
  final DocumentSnapshot project;
  const ViewMyProject({
    super.key,
    required this.courseId,
    required this.project,
    required this.projectId,
    required this.teacherId,
  });

  @override
  State<ViewMyProject> createState() => _ViewMyProjectState();
}

class _ViewMyProjectState extends State<ViewMyProject> {
  ProjectService projectService = ProjectService();
  UserService userService = UserService();
  Map<String, dynamic>? userInfo;
  late Future<void> _future;
  FocusNode focusNode = FocusNode();
  bool isTeacher = false;
  bool canComment = false;
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final commentController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    commentController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    _future = initPage();
  }

  Future<void> getUserInfo() async {
    userInfo =
        await userService.getAvatarAndDisplayName(widget.project["userId"]);
  }

  Future<void> initPage() async {
    await getUserInfo();
    if (currentUserId == widget.project["userId"] ||
        currentUserId == widget.teacherId) {
      setState(() {
        canComment = true;
      });
    }

    if (currentUserId == widget.teacherId) {
      setState(() {
        isTeacher = true;
      });
    }
  }

  Future<void> addComment() async {
    var commentData = {
      "comment": commentController.text,
      "userId": FirebaseAuth.instance.currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await projectService.addProjectComment(
        widget.courseId,
        widget.projectId,
        commentData,
      );
      log("addd comment successfully");
    } catch (e) {
      log("error add project Comment $e");
      throw Exception(e);
    }
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

  void _showGradeProjectDialog(BuildContext context) {
    TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          title: const Text(
            "Grade Project",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Row(
            children: [
              Flexible(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  cursorColor: AppColors.deepBlue,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepBlue,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,1}$'),
                    ),
                    FilteringTextInputFormatter.deny(
                      RegExp(r'^0[0-9]'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.deepBlue,
                        width: 2,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.deepBlue,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && double.tryParse(value)! > 10) {
                      _controller.text = '10';
                      _controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: _controller.text.length),
                      );
                    }
                  },
                ),
              ),
              AppSpacing.smallHorizontal,
              const Text(
                "/10",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              style: AppStyles.secondaryButtonStyle,
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              style: AppStyles.primaryButtonStyle,
              onPressed: () {
                // Handle grading logic here
                if (_controller.text.isEmpty) {
                  return;
                }

                double grade = double.parse(_controller.text);
                var updatedData = {
                  "grade": grade,
                };
                projectService.updateProject(
                  widget.courseId,
                  widget.projectId,
                  updatedData,
                );
                Navigator.of(context).pop();
              },
              child: const Text("Grade"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.ghostWhite,
      bottomSheet: !canComment
          ? const SizedBox.shrink()
          : Container(
              padding: const EdgeInsets.only(bottom: 10),
              height: MediaQuery.of(context).size.height * 0.1,
              decoration: BoxDecoration(
                color: AppColors.ghostWhite,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: TextField(
                focusNode: focusNode,
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                controller: commentController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.ghostWhite,
                  contentPadding: const EdgeInsets.all(12),
                  hintText: "Add comment",
                  border: InputBorder.none,
                  hintStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontSize: 16,
                      ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      addComment();
                      setState(() {
                        commentController.clear();
                      });
                    },
                    icon: const Icon(
                      Icons.send,
                      color: AppColors.deepBlue,
                    ),
                  ),
                ),
              ),
            ),
      appBar: AppBar(
        backgroundColor: AppColors.ghostWhite,
        surfaceTintColor: AppColors.ghostWhite,
        centerTitle: true,
        title: Text(
          widget.project["title"],
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        actions: [
          isTeacher
              ? IconButton(
                  onPressed: () {
                    _showGradeProjectDialog(context);
                  },
                  icon: const Icon(
                    Icons.edit_document,
                    color: AppColors.deepBlue,
                  ),
                )
              : const SizedBox.shrink(),
        ],
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
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: double.infinity,
                  child: Image.network(
                    widget.project["coverImage"],
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(
                    12,
                    12,
                    12,
                    MediaQuery.of(context).size.height * 0.15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.all(0),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(
                            userInfo!["photoUrl"],
                          ),
                        ),
                        title: Text(
                          userInfo!["displayName"],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      AppSpacing.mediumVertical,
                      Wrap(
                        children: [
                          const Text(
                            "Description:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          AppSpacing.smallHorizontal,
                          Text(
                            widget.project["description"],
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      const Text(
                        "Project Content:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppSpacing.smallVertical,
                      widget.project["contentImages"] == null ||
                              widget.project["contentImages"].isEmpty
                          ? const SizedBox.shrink()
                          : SizedBox(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    widget.project["contentImages"].length,
                                itemBuilder: (context, index) {
                                  String image =
                                      widget.project["contentImages"][index];
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: WidgetZoom(
                                      heroAnimationTag: image,
                                      zoomWidget: Image.network(
                                        image,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                      widget.project["files"] == null ||
                              widget.project["files"].isEmpty
                          ? const SizedBox.shrink()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Files:",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                AppSpacing.smallVertical,
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: widget.project["files"].length,
                                  itemBuilder: (context, index) {
                                    final file = widget.project["files"][index];
                                    String fileUrl =
                                        widget.project["files"][index]["url"];
                                    String fileName =
                                        widget.project["files"][index]["name"];
                                    return ListTile(
                                      contentPadding: const EdgeInsets.all(0),
                                      onTap: () {
                                        downloadFile(
                                          fileName,
                                          fileUrl,
                                        );
                                      },
                                      title: Text(
                                        file["name"],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: AppColors.deepBlue,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      leading: const Icon(
                                        Icons.file_copy_outlined,
                                        color: AppColors.deepBlue,
                                      ),
                                    );
                                  },
                                ),
                                const Text(
                                  "Project comments:",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                StreamBuilder(
                                  stream:
                                      projectService.getProjectCommentStream(
                                          widget.courseId, widget.projectId),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const SizedBox.shrink();
                                    }
                                    List<DocumentSnapshot> comments =
                                        snapshot.data!.docs;
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: comments.length,
                                      itemBuilder: (context, index) {
                                        DocumentSnapshot comment =
                                            comments[index];
                                        return FutureBuilder(
                                            future: userService
                                                .getUserNameAndAvatar(
                                              comment["userId"],
                                            ),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const SizedBox.shrink();
                                              }

                                              Map<String, dynamic> userData =
                                                  snapshot.data!;
                                              String displayName =
                                                  userData['displayName'] ??
                                                      'Mindify Member';
                                              String photoUrl = userData[
                                                      'photoUrl'] ??
                                                  'assets/images/default_avatar.png';

                                              return ListTile(
                                                leading: CircleAvatar(
                                                  radius: 14,
                                                  backgroundImage:
                                                      NetworkImage(photoUrl),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.all(0),
                                                title: Text(
                                                  displayName,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  comment["comment"],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              );
                                            });
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
