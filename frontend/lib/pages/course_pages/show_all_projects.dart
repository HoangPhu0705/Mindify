import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/course_pages/view_my_project.dart';
import 'package:frontend/services/functions/ProjectService.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:getwidget/getwidget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

class ShowAllProjects extends StatefulWidget {
  final Course course;
  const ShowAllProjects({
    super.key,
    required this.course,
  });

  @override
  State<ShowAllProjects> createState() => _ShowAllProjectsState();
}

class _ShowAllProjectsState extends State<ShowAllProjects> {
  ProjectService projectService = ProjectService();
  UserService userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: AppColors.ghostWhite,
        backgroundColor: AppColors.ghostWhite,
        centerTitle: true,
        title: const Text(
          "Student Projects",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: projectService.getProjectStream(widget.course.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No projects found.'));
                }

                List<DocumentSnapshot> projects = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: projects.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot project = projects[index];
                    String projectId = project.id;
                    String projectCoverImage = project["coverImage"];
                    String title = project["title"];
                    String userId = project["userId"];

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: userService.getAvatarAndDisplayName(userId),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return GFShimmer(
                            child: emptyBlock(context),
                          );
                        }

                        var userData = userSnapshot.data;
                        String displayName =
                            userData?['displayName'] ?? 'Unknown User';
                        String photoUrl = userData?['photoUrl'] ?? '';

                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return ViewMyProject(
                                    courseId: widget.course.id,
                                    project: project,
                                    projectId: projectId,
                                    teacherId: widget.course.instructorId,
                                  );
                                },
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height:
                                    MediaQuery.of(context).size.height * 0.25,
                                child: Image.network(
                                  projectCoverImage,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                leading: CircleAvatar(
                                  backgroundImage: photoUrl.isNotEmpty
                                      ? NetworkImage(photoUrl)
                                      : null,
                                  child: photoUrl.isEmpty
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                                title: Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(displayName),
                              ),
                              AppSpacing.mediumVertical,
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget emptyBlock(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.25,
          color: AppColors.lightGrey,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 6),
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: 8,
              color: Colors.white,
            ),
            const SizedBox(height: 6),
            Container(
              width: MediaQuery.of(context).size.width * 0.25,
              height: 8,
              color: Colors.white,
            ),
          ],
        )
      ],
    );
  }
}
