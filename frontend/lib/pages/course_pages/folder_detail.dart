import 'dart:developer';

import 'package:flutter/material.dart';
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
  //Services
  FolderService folderService = FolderService();
  CourseService courseService = CourseService();

  late Future _future;
  late List<Course> _courseList;
  late Folder folder;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _future = _initPage();
  }

  Future<List<Course>> getCourseList() async {
    //get course list from folderId
    List<dynamic> courseIds =
        await folderService.getCoursesIdFromFolder(widget.folderId);
    List<Course> courseList = [];

    for (var courseId in courseIds) {
      Course course = await courseService.getCourseById(courseId);
      courseList.add(course);
    }

    return courseList;
  }

  Future<Folder> getFolder() async {
    Folder folder = await folderService.getFolder(widget.folderId);
    return folder;
  }

  Future<void> _initPage() async {
    folder = await getFolder();
    _courseList = await getCourseList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderName),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
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

                    return MyCourseItem(
                      imageUrl: course.thumbnail,
                      title: course.title,
                      author: course.instructorName,
                      duration: course.duration,
                      students: course.students.toString(),
                      moreOnPress: () {},
                    );
                  },
                );
        },
      ),
    );
  }
}
