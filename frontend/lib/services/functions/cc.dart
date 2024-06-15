import 'package:flutter/material.dart';
import 'CourseService.dart';
import 'package:frontend/models/course.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CourseScreen(),
    );
  }
}

class CourseScreen extends StatefulWidget {
  @override
  _CourseScreenState createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final CourseService courseService = CourseService();
  Future<List<Course>>? _coursesFuture;
  Map<String, String> instructorNames = {};

  @override
  void initState() {
    super.initState();
    _coursesFuture = courseService.fetchCourses();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Course Service Test')),
      body: FutureBuilder<List<Course>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No courses found'));
          } else {
            // Fetch instructor names once courses are loaded
            _fetchInstructorNames(snapshot.data!);
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final course = snapshot.data![index];
                final instructorName = instructorNames[course.id] ?? 'Loading...';
                return ListTile(
                  title: Text(course.title),
                  subtitle: Text('Instructor: $instructorName\n${course.description}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
