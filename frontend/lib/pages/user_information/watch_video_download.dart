import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/widgets/video_player_view.dart';
import 'package:pod_player/pod_player.dart';

class VideoPlayerPage extends StatelessWidget {
  final String videoUrl;

  const VideoPlayerPage({
    super.key,
    required this.videoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.ghostWhite,
        title: const Text('Video Player'),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              VideoPlayerView(
                url: videoUrl,
                dataSourceType:
                    DataSourceType.file, // Use .file for local file path
                currentTime: 0,
                onVideoEnd: (url) {
                  // Define what happens when the video ends
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
