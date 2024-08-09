// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PopularCourse extends StatefulWidget {
  final String imageUrl;
  final String courseName;
  final String instructor;
  const PopularCourse({
    Key? key,
    required this.imageUrl,
    required this.courseName,
    required this.instructor,
  }) : super(key: key);

  @override
  State<PopularCourse> createState() => _PopularCourseState();
}

class _PopularCourseState extends State<PopularCourse> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(widget.imageUrl),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.bottomRight, colors: [
          Colors.black.withOpacity(0.9),
          Colors.black.withOpacity(0.1),
        ])),
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              widget.instructor,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              // Portrait Sketchbooking: Explore the Human Face
            ),
            Text(
              widget.courseName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
