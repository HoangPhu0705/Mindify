import 'dart:developer';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/course_pages/course_detail.dart';
import 'package:frontend/pages/course_pages/folder_detail.dart';
import 'package:frontend/services/functions/ConnectivityService.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:frontend/services/functions/EnrollmentService.dart';
import 'package:frontend/services/functions/FolderService.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/services/models/folder.dart';
import 'package:frontend/services/providers/FolderProvider.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/utils/toasts.dart';
import 'package:frontend/widgets/my_course.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:frontend/widgets/no_connection.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

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
  List<Course> selectedFolderCourses = [];
  bool _isLoading = true;
  List<Map<String, dynamic>>? _courseDataList;
  String userId = '';
  Folder? selectedFolder;
  bool isFolderLoading = false;
  late ConnectivityService _connectivityService;
  final RefreshController _courseRefreshController =
      RefreshController(initialRefresh: false);
  final RefreshController _folderRefreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    userId = userService.getUserId();
    _connectivityService = ConnectivityService();
    _loadCourseData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _connectivityService.dispose();
    _courseRefreshController.dispose();
    _folderRefreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await _loadCourseData();
    _courseRefreshController.refreshCompleted();
  }

  void _onLoading() async {
    _courseRefreshController.loadComplete();
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
            const Text(
              "Enter your list name",
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
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
        folderNameController.clear();
      },
    ).show();
  }

  void showFolderBottomSheet(BuildContext context, String courseId) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add to list',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              StreamBuilder<QuerySnapshot>(
                stream: folderService.getFolderStreamByUser(
                    FirebaseAuth.instance.currentUser!.uid),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<DocumentSnapshot> folders = snapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: folders.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = folders[index];
                        String folderId = document.id;
                        Map<String, dynamic> data =
                            folders[index].data() as Map<String, dynamic>;
                        String folderName = data['name'];
                        return Column(
                          children: [
                            ListTile(
                              onTap: () async {
                                //Add course to folder

                                await folderService.addCourseToFolder(
                                  folderId,
                                  courseId,
                                );
                                Navigator.pop(context);
                                showSuccessToast(
                                    context, "Course added to list.");
                              },
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.folder_open_outlined,
                              ),
                              title: Text(folderName),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: MyLoading(
        width: 30,
        height: 30,
        color: AppColors.deepBlue,
      ),
    );
  }

  Future<void> _loadCourseData() async {
    setState(() {
      _isLoading = true;
    });

    var enrollmentStream = enrollmentService
        .getEnrollmentStreamByUser(FirebaseAuth.instance.currentUser!.uid);
    enrollmentStream.listen((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        List<DocumentSnapshot> enrollments = snapshot.docs;
        List<Map<String, dynamic>> courseDataList = await Future.wait(
          enrollments.map((document) async {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            String courseId = data['courseId'];
            Course course = await courseService.getCourseById(courseId);
            List<String> progress =
                await enrollmentService.getProgressOfEnrollment(document.id);
            return {'course': course, 'progress': progress};
          }).toList(),
        );
        setState(() {
          _courseDataList = courseDataList;
          _isLoading = false;
        });
      } else {
        setState(() {
          _courseDataList = [];
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.ghostWhite,
        title: Text(
          'My Courses',
          style: AppStyles.largeTitleSearchPage,
        ),
        bottom: !_connectivityService.isConnected
            ? null
            : TabBar(
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
      body: !_connectivityService.isConnected
          ? NoConnection(
              onRetry: () {
                setState(() {
                  _isLoading = false;
                });
              },
            )
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.only(
                  top: 12,
                ),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _isLoading ? _buildLoadingIndicator() : courseTab(context),
                    folderTab(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget courseTab(BuildContext context) {
    if (_courseDataList == null) {
      return const Center(
        child: MyLoading(
          width: 30,
          height: 30,
          color: AppColors.deepBlue,
        ),
      );
    }

    if (_courseDataList!.isEmpty) {
      return _emptyCourse(context);
    }

    return SmartRefresher(
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      controller: _courseRefreshController,
      child: ListView.builder(
        itemCount: _courseDataList!.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          Course course = _courseDataList![index]['course'];
          List<String> progress = _courseDataList![index]['progress'];
          int totalLessons = course.lessonNum;
          int completedLessons = progress.length;

          return GestureDetector(
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => CourseDetail(
                    courseId: course.id,
                    userId: FirebaseAuth.instance.currentUser!.uid,
                  ),
                ),
              );
            },
            child: Column(
              children: [
                MyCourseItem(
                  imageUrl: course.thumbnail,
                  title: course.title,
                  lessonNum: course.lessons.length.toString(),
                  author: course.instructorName,
                  duration: course.duration,
                  students: course.students.toString(),
                  moreOnPress: () {
                    showFolderBottomSheet(context, course.id);
                  },
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Progress",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.deepBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: LinearProgressIndicator(
                              value: totalLessons > 0
                                  ? completedLessons / totalLessons
                                  : 0,
                              backgroundColor: Colors.grey.shade300,
                              color: AppColors.deepBlue,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              '$completedLessons of $totalLessons lessons',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(),
              ],
            ),
          );
        },
      ),
    );
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
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: folders.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot document = folders[index];
                  String folderId = document.id;
                  Map<String, dynamic> data =
                      folders[index].data() as Map<String, dynamic>;
                  String folderName = data['name'];
                  return Slidable(
                    key: const ValueKey(0),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      dragDismissible: false,
                      dismissible: DismissiblePane(onDismissed: () {}),
                      children: [
                        SlidableAction(
                          onPressed: (context) async {
                            await folderService.deleteFolder(folderId).then(
                              (value) {
                                showSuccessToast(context, "Folder deleted");
                              },
                            );
                          },
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.red,
                          icon: Icons.folder_delete_outlined,
                          label: "Remove",
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: AppColors.ghostWhite,
                        border: const Border(
                          top: BorderSide(color: AppColors.deepSpace, width: 1),
                          left:
                              BorderSide(color: AppColors.deepSpace, width: 1),
                          bottom:
                              BorderSide(color: AppColors.deepSpace, width: 5),
                          right:
                              BorderSide(color: AppColors.deepSpace, width: 4),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        splashColor: Colors.transparent,
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return FolderDetail(
                                  folderId: folderId,
                                  folderName: folderName,
                                );
                              },
                            ),
                          );
                        },
                        leading: const Icon(
                          Icons.folder_open_outlined,
                          color: AppColors.deepSpace,
                          size: 30,
                        ),
                        title: Text(folderName),
                        subtitle: Text('${data['courses'].length} courses'),
                      ),
                    ),
                  );
                },
              ),
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
