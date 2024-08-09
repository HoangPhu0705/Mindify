import 'dart:async';
import 'dart:developer' as dev;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:frontend/services/functions/ConnectivityService.dart';
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
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final CourseService courseService = CourseService();
  final UserService userService = UserService();

  //Controllers
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  //Variables
  Map<String, Map<String, dynamic>> instructorInfo = {};
  List<Course>? _coursesFuture;
  List<Course>? _newestCourses;
  List<Course>? _top5Courses;
  late Future<void> _future;
  String userId = '';
  List<Course> _savedCourses = [];
  Map<String, dynamic>? _categoryCourses;
  List<dynamic> categories = [];
  List<String> randomQuotes = [
    "Because you follow ",
    "Succeed in ",
    "Thrive in "
  ];
  late ConnectivityService connectivityService;
  final _pageController = PageController(initialPage: 0);

  Future<void> _initPage() async {
    try {
      instructorInfo.clear();
      _coursesFuture = await courseService.getRandomCourses();
      _top5Courses = await courseService.getTop5Courses();
      _newestCourses = await courseService.getFiveNewestCourses();

      await _loadSavedCourses();
      await _loadInstructorInfo();
      // await _loadCoursesByCategory();
    } catch (e) {
      dev.log("Error in _initPage: $e");
    }
  }

  Future<void> _loadCoursesByCategory() async {
    String uid = userService.getUserId();
    Map<String, dynamic>? userInfo = await userService.getUserInfoById(uid);

    if (userInfo == null && mounted) {
      showErrorToast(context, "There are some errors occurred");
      return;
    }

    categories = userInfo!['followedTopic'];
    var requestBody = {
      "categories": categories,
    };
    _categoryCourses = await courseService.getCategoryCourses(requestBody);
    // dev.log(_categoryCourses.toString());
  }

  Future<void> _loadInstructorInfo() async {
    if (_coursesFuture != null) {
      for (var course in _coursesFuture!) {
        if (!instructorInfo.containsKey(course.instructorId)) {
          final info = await userService.getUserInfoById(course.instructorId);
          if (info != null) {
            final data =
                await userService.getAvatarAndDisplayName(course.instructorId);
            dev.log(data.toString());
            instructorInfo[course.instructorId] = {
              ...info,
              'avatar': data!["photoUrl"],
              'displayName': data["displayName"],
            };
          }
        }
      }
    }
    if (_top5Courses != null) {
      for (var course in _top5Courses!) {
        if (!instructorInfo.containsKey(course.instructorId)) {
          final info = await userService.getUserInfoById(course.instructorId);
          if (info != null) {
            final data =
                await userService.getAvatarAndDisplayName(course.instructorId);

            instructorInfo[course.instructorId] = {
              ...info,
              'avatar': data!["photoUrl"],
              'displayName': data["displayName"],
            };
            dev.log(instructorInfo[course.instructorId].toString());
          }
        }
      }
    }
    if (_newestCourses != null) {
      for (var course in _newestCourses!) {
        if (!instructorInfo.containsKey(course.instructorId)) {
          final info = await userService.getUserInfoById(course.instructorId);
          if (info != null) {
            final data =
                await userService.getAvatarAndDisplayName(course.instructorId);

            instructorInfo[course.instructorId] = {
              ...info,
              'avatar': data!["photoUrl"],
              'displayName': data["displayName"],
            };
          }
        }
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.ghostWhite,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.initState();
    userId = userService.getUserId();
    _future = _initPage();
    connectivityService = ConnectivityService();
  }

  @override
  void dispose() {
    _pageController.dispose();
    connectivityService.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCourses() async {
    try {
      final savedCoursesNotifier =
          Provider.of<CourseProvider>(context, listen: false);
      Set<String> savedCourseIds = await userService.getSavedCourses(userId);

      List<Course> courses =
          await courseService.getCoursesByIds(savedCourseIds.toList());

      _savedCourses = courses;

      for (var id in savedCourseIds) {
        savedCoursesNotifier.saveCourse(id);
      }
    } catch (e) {
      dev.log("Error loading saved courses: $e");
    }
  }

  Future<void> saveCourse(String userId, String courseId) async {
    try {
      await userService.saveCourseForUser(userId, courseId);
      if (mounted) {
        Provider.of<CourseProvider>(context, listen: false)
            .saveCourse(courseId);
        showSavedSuccessToast(context, "Course saved!");
      }
    } catch (e) {
      dev.log("Error saving course: $e");
      if (mounted) {
        showErrorToast(context, "Failed to save course");
      }
    }
  }

  Future<void> unsaveCourse(String userId, String courseId) async {
    try {
      await userService.unsaveCourseForUser(userId, courseId);
      if (mounted) {
        Provider.of<CourseProvider>(context, listen: false)
            .unsaveCourse(courseId);
        showSuccessToast(context, "Removed saved course");
      }
    } catch (e) {
      dev.log("Error unsaving course: $e");
      if (mounted) {
        showErrorToast(context, "Failed to unsave course");
      }
    }
  }

  void _onRefresh() async {
    setState(() {
      _future = _initPage();
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ghostWhite,
      body: !connectivityService.isConnected
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off,
                    size: 100,
                    color: AppColors.blue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "You are offline",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            )
          :
      FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MyLoading(
              width: 30,
              height: 30,
              color: AppColors.deepBlue,
            );
          } else if (snapshot.hasError) {
            dev.log("FutureBuilder error: ${snapshot.error}");
            return const Center(
              child: Text("There was a problem. Please try again later."),
            );
          } else {
            return SafeArea(
              child: SmartRefresher(
                onLoading: _onLoading,
                onRefresh: _onRefresh,
                controller: _refreshController,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text("Mindify",
                          style: Theme.of(context).textTheme.headlineMedium),
                      AppSpacing.smallVertical,
                      if (_coursesFuture != null)
                        buildPopularCourses(_coursesFuture!),
                      Column(
                        children: [
                          buildCarouselCourses(
                            _top5Courses!,
                            "Recommend For You",
                            "",
                            userId,
                          ),
                          buildCarouselCourses(
                            _newestCourses!,
                            "New and Trending",
                            "",
                            userId,
                          ),
                          AppSpacing.mediumVertical,
                          // ListView.builder(
                          //   shrinkWrap: true,
                          //   physics: const NeverScrollableScrollPhysics(),
                          //   itemCount: categories.length,
                          //   itemBuilder: (context, index) {
                          //     String quotes = randomQuotes[
                          //         Random().nextInt(randomQuotes.length)];

                          //     String categoryName = categories[index];
                          //     List<dynamic> courseList =
                          //         _categoryCourses![categoryName];
                          //     List<Course> courseByCategory = courseList
                          //         .map((course) => Course.fromJson(course))
                          //         .toList();
                          //     return courseByCategory.isEmpty
                          //         ? const SizedBox.shrink()
                          //         : buildCarouselCourses(
                          //             courseByCategory,
                          //             quotes,
                          //             categoryName,
                          //             userId,
                          //           );
                          //   },
                          // ),
                        ],
                      ),
                      AppSpacing.largeVertical,
                    ],
                  ),
                ),
              ),
            );
          }
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
              final instructor = instructorInfo[course.instructorId];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => CourseDetail(
                        courseId: course.id,
                        userId: userId,
                      ),
                    ),
                  );
                },
                child: PopularCourse(
                  imageUrl: course.thumbnail,
                  courseName: course.title,
                  instructor: instructor?['displayName'] ?? 'Mindify Member',
                ),
              );
            },
          ),
        ),
        AppSpacing.smallVertical,
        SmoothPageIndicator(
          controller: _pageController,
          count: courses.length,
          effect: const ExpandingDotsEffect(
            activeDotColor: AppColors.blue,
            dotHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget buildCarouselCourses(
      List<Course> courses, String quote, String title, String userId) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: quote,
                    style: Theme.of(context).textTheme.titleLarge,
                    children: [
                      TextSpan(
                        text: title,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: AppColors.deepBlue,
                            ),
                      )
                    ],
                  ),
                ),
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
            showIndicator: false,
          ),
          itemCount: courses.length,
          itemBuilder: (context, index, realIndex) {
            final course = courses[index];
            final instructor = instructorInfo[course.instructorId];

            final isSaved =
                Provider.of<CourseProvider>(context).isCourseSaved(course.id);
            return GestureDetector(
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => CourseDetail(
                      courseId: course.id,
                      userId: userId,
                    ),
                  ),
                );
              },
              child: CourseCard(
                thumbnail: course.thumbnail,
                instructor: instructor?['displayName'] ?? 'Unknown',
                specialization:
                    instructor?['profession'] ?? 'Mindify Instructor',
                courseName: course.title,
                time: course.duration,
                numberOfLesson: course.lessonNum,
                avatar: instructor?['avatar'] != null
                    ? Image.network(instructor!['avatar'])
                    : Image.network(
                        "https://i.ibb.co/tZxYspW/default-avatar.png"),
                isSaved: isSaved,
                onSavePressed: () async {
                  if (isSaved) {
                    await unsaveCourse(userId, course.id);
                  } else {
                    await saveCourse(userId, course.id);
                  }
                },
              ),
            );
          },
        ),
        AppSpacing.mediumVertical,
      ],
    );
  }
}
