import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/pages/course_pages/course_detail.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/toasts.dart';
import 'package:frontend/widgets/course_card.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:frontend/widgets/popular_course.dart';
import 'package:provider/provider.dart';
import 'package:frontend/services/providers/CourseProvider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final CourseService courseService = CourseService();
  final UserService userService = UserService();

  late Timer _timer;
  Map<String, String> instructorNames = {};
  List<Course>? _coursesFuture;
  late Future<void> _future;
  String userId = '';
  List<Course> _savedCourses = [];

  final _pageController = PageController(initialPage: 0);

  Future<void> _initPage() async {
    _coursesFuture = await courseService.getRandomCourses();
    await _loadSavedCourses();
  }

  @override
  void initState() {
    super.initState();
    userId = userService.getUserId();
    _future = _initPage();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
    _timer.cancel();
  }

  Future<void> _loadSavedCourses() async {
    try {
      final savedCoursesNotifier =
          Provider.of<CourseProvider>(context, listen: false);
      Set<String> savedCourseIds = await userService.getSavedCourses(userId);

      List<Course> courses =
          await courseService.getCoursesByIds(savedCourseIds.toList());

      setState(() {
        _savedCourses = courses;
      });

      for (var id in savedCourseIds) {
        savedCoursesNotifier.saveCourse(id);
      }
    } catch (e) {
      log("Error loading saved courses: $e");
    }
  }

  Future<void> saveCourse(String userId, String courseId) async {
    try {
      await userService.saveCourseForUser(userId, courseId);
      Provider.of<CourseProvider>(context, listen: false).saveCourse(courseId);
      showSavedSuccessToast(context, "Course saved!");
    } catch (e) {
      log("Error saving course: $e");
      showErrorToast(context, "Failed to save course");
    }
  }

  Future<void> unsaveCourse(String userId, String courseId) async {
    try {
      await userService.unsaveCourseForUser(userId, courseId);
      Provider.of<CourseProvider>(context, listen: false)
          .unsaveCourse(courseId);
      showSuccessToast(context, "Removed saved course");
    } catch (e) {
      log("Error unsaving course: $e");
      showErrorToast(context, "Failed to unsave course");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ghostWhite,
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MyLoading(
              width: 30,
              height: 30,
              color: AppColors.deepBlue,
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text("Mindify",
                      style: Theme.of(context).textTheme.headlineMedium),
                  AppSpacing.smallVertical,
                  buildPopularCourses(_coursesFuture!),
                  AppSpacing.mediumVertical,
                  Column(
                    children: [
                      buildCarouselCourses(
                          _coursesFuture!, "Recommend For You", userId),
                      AppSpacing.mediumVertical,
                      buildCarouselCourses(
                          _coursesFuture!, "New and Trending", userId),
                    ],
                  ),
                  AppSpacing.largeVertical,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildPopularCourses(List<Course> courses) {
    return Column(
      children: [
        Container(
          height: 400,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            itemCount: courses.length,
            onPageChanged: (value) {},
            itemBuilder: (context, index) {
              final course = courses[index];
              return PopularCourse(
                imageUrl: course.thumbnail,
                courseName: course.title,
                instructor: course.instructorName,
              );
            },
          ),
        ),
        AppSpacing.smallVertical,
        SmoothPageIndicator(
          controller: _pageController,
          count: courses.length,
          effect: ExpandingDotsEffect(
            activeDotColor: AppColors.blue,
            dotHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget buildCarouselCourses(
      List<Course> courses, String title, String? userId) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        FlutterCarousel.builder(
          options: CarouselOptions(
            height: 400,
            viewportFraction: 0.85,
            disableCenter: true,
            enlargeCenterPage: true,
          ),
          itemCount: courses.length,
          itemBuilder: (context, index, realIndex) {
            final course = courses[index];

            final isSaved =
                Provider.of<CourseProvider>(context).isCourseSaved(course.id);
            return GestureDetector(
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => CourseDetail(courseId: course.id,),
                  ),
                );
              },
              child: CourseCard(
                thumbnail: course.thumbnail,
                instructor: course.instructorName,
                specialization: "Filmmaker and Youtuber",
                courseName: course.title,
                time: course.duration,
                numberOfLesson: course.lessons.length,
                avatar: "https://i.ibb.co/tZxYspW/default-avatar.png",
                isSaved: isSaved,
                onSavePressed: userId != null
                    ? () {
                        if (isSaved) {
                          unsaveCourse(userId, course.id);
                        } else {
                          saveCourse(userId, course.id);
                        }
                      }
                    : () {}, // Truyền callback
              ),
            );
          },
        ),
      ],
    );
  }
}