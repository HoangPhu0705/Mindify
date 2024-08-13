import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/course_pages/course_detail.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:frontend/services/functions/FolderService.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/services/models/folder.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/widgets/my_course.dart';
import 'package:frontend/widgets/my_loading.dart';

class FolderDetail extends StatefulWidget {
  final String folderId;
  final String folderName;

  const FolderDetail({
    super.key,
    required this.folderId,
    required this.folderName,
  });

  @override
  State<FolderDetail> createState() => _FolderDetailState();
}

class _FolderDetailState extends State<FolderDetail> {
  // Services
  FolderService folderService = FolderService();
  CourseService courseService = CourseService();

  late Future _future;
  late List<Course> _courseList;
  late Folder folder;
  bool isEditing = false;
  late TextEditingController _folderNameController;

  @override
  void initState() {
    super.initState();
    _future = _initPage();
    _folderNameController = TextEditingController(text: widget.folderName);
    _folderNameController.text = widget.folderName;
  }

  @override
  void dispose() {
    _folderNameController.dispose();
    super.dispose();
  }

  Future<List<Course>> getCourseList() async {
    // Get course list from folderId
    List<dynamic> courseIds =
        await folderService.getCoursesIdFromFolder(widget.folderId);
    List<Course> courseList = [];

    for (var courseId in courseIds) {
      Course course = await courseService.getCourseById(courseId);
      courseList.add(course);
    }

    return courseList;
  }

  Future<void> _initPage() async {
    _courseList = await getCourseList();
  }

  void _removeCourse(String courseId) {
    setState(() {
      _courseList.removeWhere((course) => course.id == courseId);
    });
  }

  Future<void> _updateFolderName() async {
    try {
      await folderService.updateFolder(
        widget.folderId,
        {'name': _folderNameController.text},
      );
      setState(() {
        isEditing = false;
      });
    } catch (e) {
      log('Error updating folder name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isEditing
            ? TextField(
                autofocus: true,
                controller: _folderNameController,
                decoration: const InputDecoration.collapsed(hintText: ""),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              )
            : Text(
                _folderNameController.text,
              ),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (isEditing) {
                _updateFolderName();
              } else {
                setState(() {
                  isEditing = true;
                });
              }
            },
          ),
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
          return _courseList.isEmpty
              ? const Center(
                  child: Text(
                    "This list is empty",
                  ),
                )
              : ListView.builder(
                  itemCount: _courseList.length,
                  itemBuilder: (context, index) {
                    Course course = _courseList[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return CourseDetail(
                                  courseId: course.id,
                                  userId:
                                      FirebaseAuth.instance.currentUser!.uid);
                            },
                          ),
                        );
                      },
                      child: MyCourseItem(
                        imageUrl: course.thumbnail,
                        title: course.title,
                        lessonNum: course.lessons.length.toString(),
                        author: course.instructorName,
                        duration: course.duration,
                        students: course.students.toString(),
                        moreOnPress: () async {
                          _showBottomSheet(
                            context,
                            widget.folderId,
                            course.id,
                            _removeCourse,
                          );
                        },
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}

_showBottomSheet(BuildContext context, String folderId, String courseId,
    Function(String) onRemoveCourse) async {
  FolderService folderService = FolderService();

  showModalBottomSheet(
    useRootNavigator: true,
    context: context,
    builder: (BuildContext context) {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.ghostWhite,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10),
          ),
        ),
        height: MediaQuery.of(context).size.height * 0.07,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(
                CupertinoIcons.trash,
                color: Colors.red,
              ),
              titleAlignment: ListTileTitleAlignment.center,
              title: const Text(
                "Remove",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
              ),
              onTap: () async {
                await folderService.removeCourseFromFolder(folderId, courseId);
                Navigator.pop(context);
                onRemoveCourse(courseId);
              },
            ),
          ],
        ),
      );
    },
  );
}
