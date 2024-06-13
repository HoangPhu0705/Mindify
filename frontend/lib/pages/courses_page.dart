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
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Icon(
              //   CupertinoIcons.play_arrow,
              //   size: 100,
              //   color: Colors.black,
              // ),
              // SizedBox(height: 16),
              // Text(
              //   'What are you waiting for?',
              //   style: Theme.of(context).textTheme.labelMedium,
              // ),
              // SizedBox(height: 8),
              // Text(
              //   'When you buy your first course, it will show up here.',
              //   textAlign: TextAlign.center,
              //   style: TextStyle(
              //     fontSize: 16,
              //     fontWeight: FontWeight.w500,
              //     color: AppColors.lightGrey,
              //   ),
              // ),
              // SizedBox(height: 16),
              // ElevatedButton(
              //   onPressed: () {
              //     // Handle button press
              //   },
              //   style: AppStyles.secondaryButtonStyle,
              //   child: Text(
              //     'See recommended courses',
              //     style: TextStyle(fontWeight: FontWeight.w400),
              //   ),
              // ),
              SavedClassItem(
                imageUrl: 'https://via.placeholder.com/150', // Placeholder image URL
                title: 'Typography That Works: Typographic Composition...',
                author: 'Ellen Lupton',
                duration: '36m',
                students: '97.5K',
              ),
            ],
          ),
          Center(
            child: Text('Downloads'),
          ),
        ],
      ),
    );
  }
}

class SavedClassItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String author;
  final String duration;
  final String students;

  const SavedClassItem({
    required this.imageUrl,
    required this.title,
    required this.author,
    required this.duration,
    required this.students,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Image.network(imageUrl, fit: BoxFit.cover, width: 100),
        title: Text(
          title,
          style: TextStyle(fontSize: 12),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(author),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.timer, size: 16),
                SizedBox(width: 4),
                Text(duration),
                SizedBox(width: 16),
                Icon(Icons.person, size: 16),
                SizedBox(width: 4),
                Text(students),
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.more_vert),
      ),
    );
  }
}