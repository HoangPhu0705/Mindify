// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/functions/ProjectService.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';

import 'package:path_provider/path_provider.dart';

class ViewMyProject extends StatefulWidget {
  final String courseId;
  final DocumentSnapshot? project;
  const ViewMyProject({
    Key? key,
    required this.courseId,
    required this.project,
  }) : super(key: key);

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
        await userService.getAvatarAndDisplayName(widget.project!["userId"]);
  }

  Future<void> initPage() async {
    await getUserInfo();
  }

  Future<void> _downloadAndOpenFile(String fileUrl) async {
    try {
      // Get the temporary directory of the device
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/${Uri.parse(fileUrl).pathSegments.last}';

      // Download the file from the URL
      final response = await http.get(Uri.parse(fileUrl));
      final file = File(filePath);

      // Write the downloaded file to the local file system
      await file.writeAsBytes(response.bodyBytes);

      // Open the file using the open_file package
      final result = await OpenFile.open(filePath);

      // Handle the result of opening the file
      if (result.type != ResultType.done) {
        // Handle errors (e.g., the file could not be opened)
        print('Error opening file: ${result.message}');
      }
    } catch (e) {
      // Handle exceptions (e.g., network issues, file write errors)
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.project!["title"],
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
                    widget.project!["coverImage"],
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
                            widget.project!["description"],
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
                      widget.project!["files"] == null
                          ? const Text("No files uploaded")
                          : ListTile(
                              onTap: () {},
                              title:
                                  Text("${widget.project!["files"][0]["url"]}"),
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
