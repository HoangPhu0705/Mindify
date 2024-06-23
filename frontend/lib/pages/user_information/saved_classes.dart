import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/widgets/my_course.dart';
import 'package:frontend/services/models/course.dart';

class SavedClasses extends StatefulWidget {
  const SavedClasses({super.key});

  @override
  State<SavedClasses> createState() => _SavedClassesState();
}

class _SavedClassesState extends State<SavedClasses> {
  final UserService _userService = UserService();
  final CourseService _courseService = CourseService();

  List<Course> _savedCourses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCourses();
  }

  Future<void> _loadSavedCourses() async {
    try {
      String userId = _userService.getUserId();
      Set<String> savedCourseIds = await _userService.getSavedCourses(userId);
      print(savedCourseIds.toString());

      List<Course> courses = await _courseService.getCoursesByIds(savedCourseIds.toList());

      setState(() {
        _savedCourses = courses;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading saved courses: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.ghostWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
          height: MediaQuery.of(context).size.height * 0.07,
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  CupertinoIcons.trash,
                  color: Colors.red,
                ),
                titleAlignment: ListTileTitleAlignment.center,
                title: Text(
                  "Remove",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  // Handle course removal
                  Navigator.pop(context);
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.ghostWhite,
        appBar: AppBar(
          surfaceTintColor: AppColors.ghostWhite,
          centerTitle: true,
          title: const Text(
            "All Saved Classes",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _savedCourses.isEmpty
                ? Center(child: Text('No saved courses'))
                : ListView.builder(
                    itemCount: _savedCourses.length,
                    itemBuilder: (context, index) {
                      final course = _savedCourses[index];
                      return MyCourseItem(
                        imageUrl: course.thumbnail,
                        title: course.title,
                        author: course.instructorName,
                        duration: course.duration,
                        students: "30",
                        moreOnPress: () {
                          _showBottomSheet(context);
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
