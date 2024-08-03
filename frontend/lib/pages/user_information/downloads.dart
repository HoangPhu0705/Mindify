import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:frontend/services/functions/EnrollmentService.dart';
import 'package:frontend/services/functions/CourseService.dart';
// import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:frontend/widgets/video_player_view.dart';
import 'package:getwidget/getwidget.dart';
import 'package:frontend/services/models/course.dart';

class Downloads extends StatefulWidget {
  final String userId;
  const Downloads({
    required this.userId,
    super.key,
  });

  @override
  State<Downloads> createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  final EnrollmentService _enrollmentService = EnrollmentService();
  final CourseService _courseService = CourseService();
  late Future<List<Map<String, dynamic>>> _downloadedLessonsFuture;

  Future<File> downloadVideo(String url, String filename) async {
    final response = await http.get(Uri.parse(url));
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$filename';
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  Future<File?> _getDownloadedVideoFile(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$filename';
    final file = File(filePath);
    if (await file.exists()) {
      return file;
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _downloadedLessonsFuture = _fetchDownloadedLessons();
  }

  Future<List<Map<String, dynamic>>> _fetchDownloadedLessons() async {
    List<Map<String, dynamic>> downloadedLessons =
        await _enrollmentService.getDownloadedLessons(widget.userId);
    List<Map<String, dynamic>> detailedLessons = [];

    for (var download in downloadedLessons) {
      String courseId = download['courseId'];
      List<String> lessonIds = List<String>.from(download['downloadedLessons']);

      for (var lessonId in lessonIds) {
        var lesson = await _fetchLesson(courseId, lessonId);
        var course = await _courseService.getCourseById(courseId);
        detailedLessons.add({
          'lesson': lesson,
          'course': course,
        });
      }
    }

    return detailedLessons;
  }

  Future<Map<String, dynamic>> _fetchLesson(
      String courseId, String lessonId) async {
    return await _courseService.getLesson(courseId, lessonId);
  }

  void _downloadAndPlayVideo(String url, String filename) async {
    File videoFile = await downloadVideo(url, filename);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoFile: videoFile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.ghostWhite,
        centerTitle: true,
        title: const Text(
          "Downloads",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _downloadedLessonsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child:
                  MyLoading(width: 30, height: 30, color: AppColors.deepBlue),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No downloaded lessons.'),
            );
          }
          var downloadedLessons = snapshot.data!;
          return ListView.separated(
            separatorBuilder: (context, index) {
              return const Divider();
            },
            itemCount: downloadedLessons.length,
            itemBuilder: (context, index) {
              var lesson = downloadedLessons[index]['lesson'];
              var course = downloadedLessons[index]['course'] as Course;
              return GFListTile(
                avatar: const Icon(
                  Icons.play_circle_fill,
                  size: 40,
                ),
                title: Text(
                  lesson['title'],
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                subTitle: Text(
                  'From Class: ${course.title}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                    fontFamily: "Poppins",
                  ),
                ),
                icon: IconButton(
                  onPressed: () {
                    _downloadAndPlayVideo(
                        lesson['link'].toString(), '${lesson['title']}.mp4');
                  },
                  icon: const Icon(
                    Icons.download_for_offline_sharp,
                    size: 32,
                    color: AppColors.deepBlue,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final File videoFile;

  VideoPlayerScreen({required this.videoFile});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Player')),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
