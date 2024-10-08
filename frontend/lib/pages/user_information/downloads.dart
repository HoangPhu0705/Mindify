import 'dart:io';
import 'package:frontend/widgets/video_player_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pod_player/pod_player.dart';
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
  String? currentVideoUrl;
  final GlobalKey<VideoPlayerViewState> _videoPlayerKey = GlobalKey();

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
        surfaceTintColor: AppColors.ghostWhite,
        centerTitle: true,
        title: const Text(
          "Downloads",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            currentVideoUrl == null
                ? const SizedBox.shrink()
                : VideoPlayerView(
                    key: _videoPlayerKey,
                    url: currentVideoUrl!,
                    dataSourceType:
                        DataSourceType.file, // Use .file for local file path
                    currentTime: 0,
                    onVideoEnd: (url) {},
                  ),
            FutureBuilder<List<File>>(
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
                  return Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_download_outlined,
                          color: AppColors.deepSpace,
                          size: 60,
                        ),
                        Text(
                          'Wherever you go',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Download your course lessons to watch them even when you are offline',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.lightGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                var downloadedVideos = snapshot.data!;
                return ListView.separated(
                  shrinkWrap: true,
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                  itemCount: downloadedVideos.length,
                  itemBuilder: (context, index) {
                    var videoFile = downloadedVideos[index];
                    String fileName =
                        videoFile.path.split('/').last.replaceAll(".mp4", "");
                    String courseName = fileName.split('_').first;
                    String videoName = fileName.split('_').last;
                    bool isPlaying = currentVideoUrl == videoFile.path;
                    return GFListTile(
                      padding: const EdgeInsets.all(20),
                      onTap: () async {
                        setState(() {
                          currentVideoUrl = videoFile.path;
                        });

                        await _videoPlayerKey.currentState!
                            .goToDownloadedVideo(currentVideoUrl!);
                      },
                      shadow: BoxShadow(
                        color: AppColors.deepSpace.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                      color: isPlaying ? AppColors.deepSpace : Colors.white,
                      avatar: isPlaying
                          ? const Icon(
                              Icons.play_circle_fill_outlined,
                              size: 32,
                              color: Colors.white,
                            )
                          : const Icon(
                              Icons.play_circle_fill_outlined,
                              size: 32,
                              color: AppColors.deepSpace,
                            ),
                      icon: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: AppColors.red,
                          ),
                          onPressed: () async {
                            // videoFile.delete();
                            // await _fetchDownloadedVideos();
                            setState(() {
                              currentVideoUrl = null;
                            });
                            if (videoFile.existsSync()) {
                              videoFile.delete();
                            }
                            _downloadedVideosFuture = _fetchDownloadedVideos();
                          }),
                      title: Text(
                        courseName,
                        maxLines: 2,
                        style: isPlaying
                            ? const TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.white,
                                overflow: TextOverflow.ellipsis,
                              )
                            : const TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                      subTitle: Text(
                        videoName,
                        maxLines: 2,
                        style: isPlaying
                            ? const TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.white,
                                overflow: TextOverflow.ellipsis,
                              )
                            : const TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
