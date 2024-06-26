import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:frontend/services/providers/CourseProvider.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/widgets/my_course.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:provider/provider.dart';

class SavedClasses extends StatefulWidget {
  const SavedClasses({super.key});

  @override
  State<SavedClasses> createState() => _SavedClassesState();
}

class _SavedClassesState extends State<SavedClasses> {
  final UserService _userService = UserService();
  final CourseService _courseService = CourseService();
  String? userId;
  List<Course> _savedCourses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    userId = _userService.getUserId();
    _loadSavedCourses();
  }

  Future<void> _loadSavedCourses() async {
    try {
      // final savedCoursesNotifier =
      //     Provider.of<CourseProvider>(context, listen: false);
      Set<String> savedCourseIds = await _userService.getSavedCourses(userId!);
      List<Course> courses = [];
      log('Saved Course IDs: $savedCourseIds');
      
      for (String id in savedCourseIds) {
        Course? course = await _courseService.getCourseById(id);
        if (course != null) {
          courses.add(course);
        }
      }
      
      setState(() {
        _savedCourses = courses;
        _isLoading = false;
      });

      // for (var id in savedCourseIds) {
      //   savedCoursesNotifier.saveCourse(id);
      // }
    } catch (e) {
      log("Error loading saved courses: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showBottomSheet(BuildContext context, String courseId) {
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
                onTap: () {
                  _userService.unsaveCourseForUser(userId!, courseId).then((_) {
                    Provider.of<CourseProvider>(context, listen: false)
                        .unsaveCourse(courseId);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "All Saved Classes",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.ghostWhite,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.ghostWhite,
        ),
        child: _isLoading
            ? const MyLoading(
                width: 30,
                height: 30,
                color: AppColors.deepBlue,
              )
            : Consumer<CourseProvider>(
                builder: (context, courseProvider, child) {
                  final savedCourseIds = courseProvider.savedCourses;
                  final filteredCourses = _savedCourses
                      .where((course) => savedCourseIds.contains(course.id))
                      .toList();
                  return _savedCourses.isEmpty
                      ? const Center(
                          child: Text(
                            'No saved courses',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredCourses.length,
                          itemBuilder: (context, index) {
                            final course = filteredCourses[index];
                            return MyCourseItem(
                              imageUrl: course.thumbnail,
                              title: course.title,
                              author: course.instructorName,
                              duration: course.duration,
                              students: course.students.toString(),
                              moreOnPress: () {
                                _showBottomSheet(context, course.id);
                              },
                            );
                          },
                        );
                },
              ),
      ),
    );
  }
}
