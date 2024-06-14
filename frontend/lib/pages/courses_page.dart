// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/my_course.dart';

class MyCoursePage extends StatefulWidget {
  @override
  _MyCoursesPageState createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursePage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.ghostWhite,
        title: Text('My courses', style: AppStyles.largeTitleSearchPage),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Courses'),
            Tab(text: 'My Lists'),
          ],
          labelColor: Colors.black,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorColor: Colors.black,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: 3,
                itemBuilder: (context, index) {
                  return MyCourseItem(
                    imageUrl:
                        'https://static.skillshare.com/uploads/video/thumbnails/3d4e26f38f2cb702b655467f0be55771/448-252', // Placeholder image URL
                    title:
                        "The Professional Repeat: A Surface Designer Guide to Print Production",
                    author: 'Ellen Lupton',
                    duration: '3m',
                    students: '97.5K',
                  );
                },
              )
            ],
          ),
          Center(
            child: Text('Downloads'),
          ),
        ],
      ),
    );
  }

  Widget _emptyCourse(BuildContext context) {
    return Column(
      children: [
        Icon(
          CupertinoIcons.play_arrow,
          size: 100,
          color: Colors.black,
        ),
        SizedBox(height: 16),
        Text(
          'What are you waiting for?',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        SizedBox(height: 8),
        Text(
          'When you buy your first course, it will show up here.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.lightGrey,
          ),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Handle button press
          },
          style: AppStyles.secondaryButtonStyle,
          child: Text(
            'See recommended courses',
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
}
