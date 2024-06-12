import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/styles.dart';

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
        title: Text('My courses'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Courses'),
            Tab(text: 'Downloads'),
          ],
          labelColor: Colors.black,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorColor: Colors.black,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
              ),
            ),
          ),
          Center(
            child: Text('Downloads'),
          ),
        ],
      ),
    );
  }
}
