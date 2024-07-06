import 'dart:developer';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:frontend/services/functions/EnrollmentService.dart';
import 'package:frontend/services/functions/FolderService.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/services/models/folder.dart';
import 'package:frontend/services/providers/FolderProvider.dart';
import 'package:frontend/services/providers/EnrollmentProvider.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/my_course.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:provider/provider.dart';

class MyCoursePage extends StatefulWidget {
  @override
  _MyCoursesPageState createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursePage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final folderNameController = TextEditingController();

  final userService = UserService();
  final enrollmentService = EnrollmentService();
  final folderService = FolderService();
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
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _showCreateFolderDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.bottomSlide,
      btnOkText: "Create",
      btnOkColor: AppColors.deepSpace,
      btnCancelOnPress: () {},
      dialogBorderRadius: BorderRadius.circular(5),
      body: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            Text(
              "Enter your list name",
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
              ),
            ),
            TextField(
              controller: folderNameController,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: AppColors.blue,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: AppColors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      btnOkOnPress: () async {
        var data = {
          'name': folderNameController.text,
          'courses': [],
          'userId': userId,
        };
        await folderService.createFolder(data);
      },
    ).show();
  }

  // void _addCourseToFolder(String courseId) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Consumer<FolderProvider>(
  //         builder: (context, folderProvider, child) {
  //           return folderProvider.isLoading
  //               ? Center(child: CircularProgressIndicator())
  //               : ListView.builder(
  //                   itemCount: folderProvider.folders.length,
  //                   itemBuilder: (context, index) {
  //                     Folder folder = folderProvider.folders[index];
  //                     return ListTile(
  //                       title: Text(folder.name),
  //                       onTap: () {
  //                         folderProvider.addCourseToFolder(folder.id, courseId);
  //                         Navigator.of(context).pop();
  //                       },
  //                     );
  //                   },
  //                 );
  //         },
  //       );
  //     },
  //   );
  // }

  // Future<void> _showFolderCourses(Folder folder) async {
  //   // Fetch detailed course information
  //   List<Course> courses = [];
  //   for (String courseId in folder.courses) {
  //     Course course = await courseService.getCourseById(courseId);
  //     courses.add(course);
  //   }
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
              //Courses tab
              courseTab(context),
              folderTab(context),
            ],
          ),
        ));
  }

  Widget folderTab(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateFolderDialog(context);
        },
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: folderService
            .getFolderStreamByUser(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<DocumentSnapshot> folders = snapshot.data!.docs;
            return ListView.builder(
              itemCount: folders.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data =
                    folders[index].data() as Map<String, dynamic>;
                String folderName = data['name'];
                // Replace with your actual folder widget
                return ListTile(
                  leading: const Icon(
                    Icons.folder,
                  ),
                  title: Text(folderName),
                );
              },
            );
          } else {
            return const Center(
              child: Text('No folders available'),
            );
          }
        },
      ),
    );
  }

  Widget courseTab(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: enrollmentService
          .getEnrollmentStreamByUser(FirebaseAuth.instance.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<DocumentSnapshot> enrollments = snapshot.data!.docs;
          return FutureBuilder<List<Course>>(
            future: Future.wait(
              enrollments.map((document) async {
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String courseId = data['courseId'];
                return await courseService.getCourseById(courseId);
              }).toList(),
            ),
            builder: (context, courseSnapshot) {
              if (courseSnapshot.connectionState == ConnectionState.waiting) {
                return const MyLoading(
                  width: 30,
                  height: 30,
                  color: AppColors.deepBlue,
                );
              } else if (courseSnapshot.hasData) {
                List<Course> courses = courseSnapshot.data!;
                return ListView.builder(
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    log(courses.length.toString());
                    Course course = courses[index];
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
              } else {
                return _emptyCourse(context);
              }
            },
          );
        } else {
          return _emptyCourse(context);
        }
      },
    );
  }

  Widget _emptyCourse(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          CupertinoIcons.play_arrow,
          size: 100,
          color: Colors.black,
        ),
        AppSpacing.mediumVertical,
        Text(
          'What are you waiting for?',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        AppSpacing.smallVertical,
        const Text(
          'When you buy your first course, it will show up here.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.lightGrey,
          ),
        ),
        AppSpacing.mediumVertical,
        ElevatedButton(
          onPressed: () {
            // Handle button press
          },
          style: AppStyles.secondaryButtonStyle,
          child: const Text(
            'See recommended courses',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
