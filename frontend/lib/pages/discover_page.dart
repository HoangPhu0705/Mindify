import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:frontend/pages/course_pages/course_detail.dart';
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
  int _currentTopCourse = 0;
  final _pageController = PageController(initialPage: 0);
  late Timer _timer;
  final _courseController =
      PageController(viewportFraction: 0.8, keepPage: false, initialPage: 0);

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
  }

  @override
  void dispose() {
    _pageController.dispose();
    _courseController.dispose();
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
                  onPageChanged: (value) {
                    _currentTopCourse = value;
                  },
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
              FlutterCarousel.builder(
                options: CarouselOptions(
                  height: 400,
                  viewportFraction: 0.85,
                  disableCenter: true,
                  enlargeCenterPage: true,
                ),
                itemCount: 5,
                itemBuilder: (context, index, realIndex) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (
                            context,
                          ) =>
                              CourseDetail(),
                        ),
                      );
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
              AppSpacing.mediumVertical,
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
              FlutterCarousel.builder(
                options: CarouselOptions(
                  height: 400,
                  viewportFraction: 0.85,
                  disableCenter: true,
                  enlargeCenterPage: true,
                ),
                itemCount: 5,
                itemBuilder: (context, index, realIndex) {
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
              AppSpacing.mediumVertical,
            ],
          ),
        ),
      ),
    );
  }
}

class CustomScrollPhysics extends ScrollPhysics {
  final double itemDimension;

  const CustomScrollPhysics(
      {required this.itemDimension, ScrollPhysics? parent})
      : super(parent: parent);

  @override
  CustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomScrollPhysics(
        itemDimension: itemDimension, parent: buildParent(ancestor));
  }

  double _getPage(ScrollMetrics position, double portion) {
    // <--
    return (position.pixels + portion) / itemDimension;
    // -->
  }

  double _getPixels(double page, double portion) {
    // <--
    return (page * itemDimension) - portion;
    // -->
  }

  double _getTargetPixels(
    ScrollMetrics position,
    Tolerance tolerance,
    double velocity,
    double portion,
  ) {
    // <--
    double page = _getPage(position, portion);
    // -->
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    // <--
    return _getPixels(page.roundToDouble(), portion);
    // -->
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    final Tolerance tolerance = this.tolerance;
    // <--
    final portion = (position.extentInside - itemDimension) / 2;
    final double target =
        _getTargetPixels(position, tolerance, velocity, portion);
    // -->
    if (target != position.pixels) {
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}
