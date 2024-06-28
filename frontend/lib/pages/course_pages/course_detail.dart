import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/course_pages/discussion_tab.dart';
import 'package:frontend/pages/course_pages/lesson_tab.dart';
import 'package:frontend/pages/course_pages/submit_project_tab.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/widgets/video_player_view.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:video_player/video_player.dart';

class CourseDetail extends StatefulWidget {
  final String courseId;

  const CourseDetail({super.key, required this.courseId});

  @override
  State<CourseDetail> createState() => _CourseDetailState();
}

class _CourseDetailState extends State<CourseDetail>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool isFollowed = false;
  Course? course;
  bool isLoading = true;
  String? _currentVideoUrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchCourseDetails();
  }

  Future<void> _fetchCourseDetails() async {
    try {
      final courseService = CourseService();
      final fetchedCourse = await courseService.getCourseById(widget.courseId);
      setState(() {
        course = fetchedCourse;
        isLoading = false;
        if (course!.lessons.isNotEmpty) {
          _currentVideoUrl = course!.lessons.first.link;
        }
      });
    } catch (e) {
      print("Error fetching course details: $e");
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> followUser() async {
    setState(() {
      isFollowed = !isFollowed;
    });
  }

  void _onLessonTap(String videoUrl) {
    print('Tapped lesson with video URL: $videoUrl');
    setState(() {
      _currentVideoUrl = videoUrl;
      print('Current video URL updated to: $_currentVideoUrl');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: AppColors.ghostWhite,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.xmark,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(CupertinoIcons.bookmark),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(CupertinoIcons.share),
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  if (_currentVideoUrl != null)
                    VideoPlayerView(
                      url: _currentVideoUrl!,
                      dataSourceType: DataSourceType.network,
                    ),
                  TabBar(
                    tabAlignment: TabAlignment.center,
                    isScrollable: true,
                    controller: _tabController,
                    splashFactory: NoSplash.splashFactory,
                    tabs: const [
                      Tab(text: 'Lessons'),
                      Tab(text: 'Projects'),
                      Tab(text: 'Discussions'),
                      Tab(text: 'Notes'),
                    ],
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    unselectedLabelColor: Colors.black,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorColor: Colors.black,
                    indicatorWeight: 3,
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        LessonTab(
                          isFollowed: isFollowed,
                          followUser: followUser,
                          course: course!,
                          onLessonTap: _onLessonTap,
                        ),
                        SubmitProject(
                          course: course!,
                        ),
                        Discussion(),
                        Center(
                          child: Text("Notes"),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      color: Colors.white,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Text("Buy Course: ${course!.price}"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
