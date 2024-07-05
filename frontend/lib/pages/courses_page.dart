import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:frontend/services/functions/EnrollmentService.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/services/models/folder.dart';
import 'package:frontend/services/providers/FolderProvider.dart';
import 'package:frontend/services/providers/EnrollmentProvider.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/my_course.dart';
import 'package:provider/provider.dart';

class MyCoursePage extends StatefulWidget {
  @override
  _MyCoursesPageState createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursePage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final userService = UserService();
  final enrollmentService = EnrollmentService();
  final courseService = CourseService();
  List<String> courseIdEnrolled = [];
  List<Course> enrolledCourses = [];
  List<Course> selectedFolderCourses = []; // Declare the list here
  bool isLoading = true;
  String userId = '';
  Folder? selectedFolder;
  bool isFolderLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    userId = userService.getUserId();
    _fetchEnrolledCourses();
    Provider.of<EnrollmentProvider>(context, listen: false).addListener(() {
      if (Provider.of<EnrollmentProvider>(context, listen: false).isEnrolled) {
        _fetchEnrolledCourses();
        Provider.of<EnrollmentProvider>(context, listen: false).reset();
      }
    });
    Provider.of<FolderProvider>(context, listen: false).fetchFolders(userId);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _fetchEnrolledCourses() async {
    try {
      List<Course> courses = [];
      courseIdEnrolled = await enrollmentService.getUserEnrollments(userId);
      log(courseIdEnrolled.toString());
      for (String courseId in courseIdEnrolled) {
        Course course = await courseService.getCourseById(courseId);
        courses.add(course);
      }
      setState(() {
        enrolledCourses = courses;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching enrolled courses: $e');
    }
  }

  void _showCreateFolderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String folderName = '';
        return AlertDialog(
          title: Text('Create Folder'),
          content: TextField(
            onChanged: (value) {
              folderName = value;
            },
            decoration: InputDecoration(hintText: "Folder Name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('CREATE'),
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<FolderProvider>(context, listen: false)
                    .createFolder(userId, folderName);
              },
            ),
          ],
        );
      },
    );
  }

  void _addCourseToFolder(String courseId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Consumer<FolderProvider>(
          builder: (context, folderProvider, child) {
            return folderProvider.isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: folderProvider.folders.length,
                    itemBuilder: (context, index) {
                      Folder folder = folderProvider.folders[index];
                      return ListTile(
                        title: Text(folder.name),
                        onTap: () {
                          folderProvider.addCourseToFolder(folder.id, courseId);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  );
          },
        );
      },
    );
  }

  Future<void> _showFolderCourses(Folder folder) async {
    setState(() {
      selectedFolder = folder;
      isFolderLoading = true;
    });

    // Fetch detailed course information
    List<Course> courses = [];
    for (String courseId in folder.courses) {
      Course course = await courseService.getCourseById(courseId);
      courses.add(course);
    }

    setState(() {
      selectedFolderCourses = courses;
      isFolderLoading = false;
    });
  }

  void _goBackToFolderList() {
    setState(() {
      selectedFolder = null;
    });
  }

  // void _deleteFolder(Folder folder) {
  //   Provider.of<FolderProvider>(context, listen: false).deleteFolder(folder.id);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.ghostWhite,
        title: Text('My Courses', style: AppStyles.largeTitleSearchPage),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Courses'),
            Tab(text: 'My Lists'),
          ],
          labelColor: Colors.black,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorColor: Colors.black,
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            isLoading
                ? Center(child: CircularProgressIndicator())
                : enrolledCourses.isEmpty
                    ? _emptyCourse(context)
                    : ListView.builder(
                        itemCount: enrolledCourses.length,
                        itemBuilder: (context, index) {
                          Course course = enrolledCourses[index];
                          return MyCourseItem(
                            imageUrl: course.thumbnail,
                            title: course.title,
                            author: course.instructorName,
                            duration: course.duration,
                            students: course.students.toString(),
                            moreOnPress: () => _addCourseToFolder(course.id),
                          );
                        },
                      ),
            selectedFolder == null
                ? Consumer<FolderProvider>(
                    builder: (context, folderProvider, child) {
                      return folderProvider.isLoading
                          ? Center(child: CircularProgressIndicator())
                          : folderProvider.folders.isEmpty
                              ? Center(child: Text('No folders found'))
                              : ListView.builder(
                                  itemCount: folderProvider.folders.length,
                                  itemBuilder: (context, index) {
                                    Folder folder =
                                        folderProvider.folders[index];
                                    return ListTile(
                                      leading: Icon(Icons.folder),
                                      title: Text(folder.name),
                                      subtitle: Text(
                                          '${folder.courses.length} courses'),
                                      trailing: PopupMenuButton(
                                        onSelected: (value) {
                                          // if (value == 'delete') {
                                          //   _deleteFolder(folder);
                                          // }
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Delete'),
                                          ),
                                        ],
                                      ),
                                      onTap: () => _showFolderCourses(folder),
                                    );
                                  },
                                );
                    },
                  )
                : isFolderLoading
                    ? Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: _goBackToFolderList,
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: selectedFolderCourses.length,
                              itemBuilder: (context, index) {
                                Course course = selectedFolderCourses[index];
                                return MyCourseItem(
                                  imageUrl: course.thumbnail,
                                  title: course.title,
                                  author: course.instructorName,
                                  duration: course.duration,
                                  students: course.students.toString(),
                                  moreOnPress: () {},
                                );
                              },
                            ),
                          ),
                        ],
                      ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateFolderDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
    );
  }

  Widget _emptyCourse(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          CupertinoIcons.play_arrow,
          size: 100,
          color: Colors.black,
        ),
        SizedBox(height: 16),
        Text(
          'What are you waiting for?',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        SizedBox(height: 8),
        Text(
          'When you buy your first course, it will show up here.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.lightGrey,
          ),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Handle button press
          },
          style: AppStyles.secondaryButtonStyle,
          child: Text(
            'See recommended courses',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
