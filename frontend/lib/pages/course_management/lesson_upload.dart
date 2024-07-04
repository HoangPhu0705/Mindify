import 'package:flutter/material.dart';

class LessonUpload extends StatefulWidget {
  const LessonUpload({super.key});

  @override
  State<LessonUpload> createState() => _LessonUploadState();
}

class _LessonUploadState extends State<LessonUpload> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lesson upload"),
      ),
      body: SafeArea(
        child: Text("Video upload"),
      ),
    );
  }
}
