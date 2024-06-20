import 'dart:async';
import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:frontend/models/course.dart';
import 'package:frontend/pages/course_pages/course_detail.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/widgets/course_card.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:frontend/widgets/popular_course.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  //Services
  final CourseService courseService = CourseService();

  //Variables
  // int _currentTopCourse = 0;
  late Timer _timer;
  Map<String, String> instructorNames = {};
  List<Course>? _coursesFuture;
  late Future<void> _future;

  //Controllers

  final _pageController = PageController(initialPage: 0);

  Future<void> _initPage() async {
    _coursesFuture = await courseService.getRandomCourses();
  }

  @override
  void initState() {
    super.initState();

    _future = _initPage();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
    _timer.cancel();
  }

  void addFavoriteCourse(int id) {
    try {} catch (e) {
      log("Error adding");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return MyLoading(width: 30, height: 30);
            }

            return SingleChildScrollView(
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
                          _coursesFuture!, "Recommend For You"),
                      AppSpacing.mediumVertical,
                      buildCarouselCourses(_coursesFuture!, "New and Trending"),
                    ],
                  ),
                  AppSpacing.largeVertical,
                ],
              ),
            );
          },
        ),
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

  Widget buildCarouselCourses(List<Course> courses, String title) {
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
            return GestureDetector(
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => CourseDetail(),
                  ),
                );
              },
              child: CourseCard(
                thumbnail: course.thumbnail,
                instructor: course.instructorName,
                specialization: "Filmaker and Youtuber",
                courseName: course.title,
                time: course.duration,
                numberOfLesson: course.lessons.length,
                avatar: "https://i.ibb.co/tZxYspW/default-avatar.png",
              ),
            );
          },
        ),
      ],
    );
  }
}
