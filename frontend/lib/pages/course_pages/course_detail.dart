// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/course_pages/lesson_tab.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/video_player_view.dart';
import 'package:video_player/video_player.dart';

class CourseDetail extends StatefulWidget {
  const CourseDetail({super.key});

  @override
  State<CourseDetail> createState() => _CourseDetailState();
}

class _CourseDetailState extends State<CourseDetail>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool isFollowed = false;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> followUser() async {
    setState(() {
      isFollowed = !isFollowed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.ghostWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              offset: Offset(0, -1),
            ),
          ],
        ),
        height: MediaQuery.of(context).size.height * 0.1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "đ149.000",
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            AppSpacing.mediumHorizontal,
            Expanded(
              child: TextButton(
                style: AppStyles.primaryButtonStyle,
                onPressed: () {},
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Purchase",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
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
      body: SafeArea(
        child: Column(
          children: [
            VideoPlayerView(
              url:
                  "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
              dataSourceType: DataSourceType.network,
            ),
            TabBar(
              controller: _tabController,
              splashFactory: NoSplash.splashFactory,
              tabs: const [
                Tab(text: 'Lessons'),
                Tab(text: 'Projects'),
                Tab(text: 'Discussions'),
              ],
              labelColor: Colors.black,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
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
                  ),
                  Center(child: Text("Projects")),
                  Center(child: Text("Discussions")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
