import 'dart:developer';
import 'dart:io';
import 'package:frontend/pages/user_information/watch_video_download.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:getwidget/getwidget.dart';

class Downloads extends StatefulWidget {
  const Downloads({super.key});

  @override
  State<Downloads> createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  late Future<List<File>> _downloadedVideosFuture;

  @override
  void initState() {
    super.initState();
    _downloadedVideosFuture = _fetchDownloadedVideos();
  }

  Future<String?> _getUserIdFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<List<File>> _fetchDownloadedVideos() async {
    String? userId = await _getUserIdFromPreferences();
    if (userId == null) {
      throw Exception('User ID not found in SharedPreferences');
    }

    final directory = await getApplicationDocumentsDirectory();
    final userDirectory = Directory('${directory.path}/$userId');

    if (!await userDirectory.exists()) {
      return [];
    }

    List<FileSystemEntity> files = userDirectory.listSync();
    List<File> videos = files.whereType<File>().where((file) {
      return file.path.endsWith('.mp4');
    }).toList();

    return videos;
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
      body: FutureBuilder<List<File>>(
        future: _downloadedVideosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: MyLoading(
                width: 30,
                height: 30,
                color: AppColors.deepBlue,
              ),
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
          var downloadedVideos = snapshot.data!;
          return ListView.separated(
            separatorBuilder: (context, index) {
              return const Divider();
            },
            itemCount: downloadedVideos.length,
            itemBuilder: (context, index) {
              var videoFile = downloadedVideos[index];
              String fileName = videoFile.path.split('/').last;

              return GFListTile(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return VideoPlayerPage(
                          videoUrl: videoFile.path,
                        );
                      },
                    ),
                  );
                },
                avatar: const Icon(
                  Icons.play_circle_fill,
                  size: 40,
                  color: AppColors.deepSpace,
                ),
                title: Text(
                  fileName,
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
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
