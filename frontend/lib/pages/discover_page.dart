import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/widgets/course_card.dart';
import 'package:frontend/widgets/popular_course.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final _pageController = PageController();
  final _courseController =
      PageController(viewportFraction: 0.8, keepPage: false, initialPage: 0);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _courseController.dispose();
    super.dispose();
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              Text("Mindify",
                  style: Theme.of(context).textTheme.headlineMedium),
              AppSpacing.smallVertical,
              Container(
                height: 400,
                width: double.infinity,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return PopularCourse(
                        imageUrl:
                            "https://cdn.domestika.org/ar_16:9,c_fill,dpr_1.0,f_auto,pg_1,q_auto:eco,t_base_params,w_768/v1660032015/course-covers/000/002/846/2846-original.jpg?1660032015",
                        courseName:
                            "Portrait Sketchbooking: Explore the Human Face",
                        instructor: " Gabriela Niko");
                  },
                ),
              ),
              AppSpacing.smallVertical,
              SmoothPageIndicator(
                controller: _pageController,
                count: 5,
                effect: ExpandingDotsEffect(
                  activeDotColor: AppColors.blue,
                  dotHeight: 4,
                ),
              ),
              AppSpacing.mediumVertical,
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      "Recommend For You",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              AppSpacing.smallVertical,
              SizedBox(
                height: 400,
                child: PageView.builder(
                  padEnds: false,
                  controller: _courseController,
                  physics: CustomPageViewScrollPhysics(),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        log("choose course $index");
                      },
                      child: CourseCard(
                        thumbnail:
                            "https://cdn.domestika.org/ar_16:9,c_fill,dpr_1.0,f_auto,pg_1,q_auto:eco,t_base_params,w_768/v1637746204/course-covers/000/001/745/1745-original.jpg?1637746204",
                        instructor: "Jordy Vandeput",
                        specializaion: "Filmaker and Youtuber",
                        courseName:
                            "Advanced Video Editing with Adobe Premiere Pro",
                        time: 53,
                        numberOfLesson: 9,
                        avatar: "https://avatar.iran.liara.run/public/boy",
                      ),
                    );
                  },
                ),
              ),
              AppSpacing.smallVertical,
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      "New and Trending",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 400,
                child: PageView.builder(
                  padEnds: false,
                  physics: CustomPageViewScrollPhysics(),
                  controller: _courseController,
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        log("choose course $index");
                      },
                      child: CourseCard(
                        thumbnail:
                            "https://cdn.domestika.org/ar_16:9,c_fill,dpr_1.0,f_auto,pg_1,q_auto:eco,t_base_params,w_768/v1637746204/course-covers/000/001/745/1745-original.jpg?1637746204",
                        instructor: "Jordy Vandeput",
                        specializaion: "Filmaker and Youtuber",
                        courseName:
                            "Advanced Video Editing with Adobe Premiere Pro",
                        time: 53,
                        numberOfLesson: 9,
                        avatar: "https://avatar.iran.liara.run/public/boy",
                      ),
                    );
                  },
                ),
              ),
              AppSpacing.mediumVertical,
            ],
          ),
        ),
      ),
    );
  }
}

class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor)!);
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 100,
        damping: 0.8,
      );
}
