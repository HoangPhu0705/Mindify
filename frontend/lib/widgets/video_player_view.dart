import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:pod_player/pod_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoPlayerView extends StatefulWidget {
  final String url;
  final DataSourceType dataSourceType;
  const VideoPlayerView({
    super.key,
    required this.url,
    required this.dataSourceType,
  });

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late VideoPlayerController _videoPlayerController;
  late PodPlayerController _podPlayerController;
  late Future<void> _future;
  String? fileName;

  Future<void> initVideoPlayer() async {
    await _videoPlayerController.initialize();

    fileName = await VideoThumbnail.thumbnailFile(
      video: widget.url,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.PNG,
      maxHeight: 300,
      maxWidth: 300,
      quality: 75,
    );

    log("FileName: ");
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _podPlayerController = PodPlayerController(
      playVideoFrom: PlayVideoFrom.network(widget.url),
      podPlayerConfig: PodPlayerConfig(
        autoPlay: false,
        isLooping: false,
      ),
    )..initialise();

    switch (widget.dataSourceType) {
      case DataSourceType.network:
        _videoPlayerController = VideoPlayerController.network(widget.url);
        break;
      case DataSourceType.file:
        _videoPlayerController = VideoPlayerController.file(File(widget.url));
        break;
      case DataSourceType.asset:
        _videoPlayerController = VideoPlayerController.asset(widget.url);
        break;
      case DataSourceType.contentUri:
        _videoPlayerController =
            VideoPlayerController.contentUri(Uri.parse(widget.url));
        break;
    }
    _future = initVideoPlayer();
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
    _podPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(110.0),
              child: LoadingIndicator(
                indicatorType: Indicator.lineSpinFadeLoader,
                colors: [AppColors.blue],
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.done &&
            fileName != null) {
          return PodVideoPlayer(
            controller: _podPlayerController,
            podProgressBarConfig: PodProgressBarConfig(
              padding: EdgeInsets.symmetric(horizontal: 12),
              backgroundColor: Colors.white,
              playingBarColor: AppColors.cream,
              circleHandlerColor: AppColors.cream,
            ),
            alwaysShowProgressBar: false,
            videoAspectRatio: 16 / 9,
          );
        }

        return Center(child: Text("Failed to load video"));
      },
    );
  }
}
