// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/functions/ProjectService.dart';

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

  initState() {
    super.initState();
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
      body: Container(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              child: Image.network(
                widget.project!["coverImage"],
                fit: BoxFit.cover,
              ),
            )
          ],
        ),
      ),
    );
  }
}
