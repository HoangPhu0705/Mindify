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
import 'package:frontend/widgets/popular_course.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  int _currentTopCourse = 0;
  final _pageController = PageController(initialPage: 0);
  late Timer _timer;
  final _courseController =
      PageController(viewportFraction: 0.8, keepPage: false, initialPage: 0);
  final CourseService courseService = CourseService();
  Future<List<Course>>? _coursesFuture;
  Map<String, String> instructorNames = {};
  Future<List<Course>>? _courseRandom;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 4), (Timer timer) {
      if (_currentTopCourse < 4) {
        _currentTopCourse++;
      } else {
        _currentTopCourse = 0;
      }

      _pageController.animateToPage(
        _currentTopCourse,
        duration: Duration(milliseconds: 350),
        curve: Curves.ease,
      );
    });
    _coursesFuture = courseService.fetchCourses();
    _courseRandom = courseService.getRandomCourses();
  }

  Future<void> _fetchInstructorNames(List<Course> courses) async {
    for (var course in courses) {
      final name = await courseService.getInstructorName(course.instructorId);
      setState(() {
        instructorNames[course.id] = name;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _courseController.dispose();
    super.dispose();
    _timer.cancel();
    _timer.cancel();
  }

  void addFavoriteCourse(int id) {
    try {} catch (e) {
      log("Error adding");
    }
  }

  Widget buildPopularCourses(List<Course> courses) {
    _fetchInstructorNames(courses);
    return Column(
      children: [
        Container(
          height: 400,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            itemCount: courses.length,
            onPageChanged: (value) {
              setState(() {
                _currentTopCourse = value;
              });
            },
            itemBuilder: (context, index) {
              final course = courses[index];
              final instructorName = instructorNames[course.id] ?? 'Loading...';
              return PopularCourse(
                imageUrl: course.thumbnail,
                courseName: course.title,
                instructor: instructorName,
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
            final instructorName = instructorNames[course.id] ?? 'Loading...';
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
                instructor: instructorName,
                specialization: "Filmaker and Youtuber",
                courseName: course.title,
                time: 9,
                numberOfLesson: course.lessons.length,
                avatar: "https://avatar.iran.liara.run/public/boy",
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Text("Mindify", style: Theme.of(context).textTheme.headlineMedium),
              AppSpacing.smallVertical,
              FutureBuilder<List<Course>>(
                future: _coursesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No courses found'));
                  } else {
                    return buildPopularCourses(snapshot.data!);
                  }
                },
              ),
              AppSpacing.mediumVertical,
              FutureBuilder<List<Course>>(
                future: _coursesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No courses found'));
                  } else {
                    return Column(
                      children: [
                        buildCarouselCourses(snapshot.data!, "Recommend For You"),
                        AppSpacing.mediumVertical,
                        buildCarouselCourses(snapshot.data!, "New and Trending"),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
