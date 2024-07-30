// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/functions/ProjectService.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:open_file_plus/open_file_plus.dart';

import 'package:path_provider/path_provider.dart';
import 'package:widget_zoom/widget_zoom.dart';

class ViewMyProject extends StatefulWidget {
  final String courseId;
  final DocumentSnapshot project;
  const ViewMyProject({
    super.key,
    required this.courseId,
    required this.project,
  });

  @override
  State<ViewMyProject> createState() => _ViewMyProjectState();
}

class _ViewMyProjectState extends State<ViewMyProject> {
  ProjectService projectService = ProjectService();
  UserService userService = UserService();
  Map<String, dynamic>? userInfo;
  late Future<void> _future;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  padding: const EdgeInsets.all(12),
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
                      widget.project["contentImages"] == null
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
                      widget.project["files"] == null
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
                                        ),
                                      ),
                                      leading: const Icon(Icons.file_copy),
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
