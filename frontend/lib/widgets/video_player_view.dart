import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:video_player/video_player.dart';
import 'package:pod_player/pod_player.dart';

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
  late PodPlayerController _podPlayerController;
  late Future<void> _future;

  Future<void> initVideoPlayer() async {
    _podPlayerController = PodPlayerController(
      playVideoFrom: PlayVideoFrom.network(widget.url),
      podPlayerConfig: const PodPlayerConfig(
        autoPlay: false,
        isLooping: false,
        videoQualityPriority: [360, 720],
      ),
    )..initialise();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _future = initVideoPlayer();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _podPlayerController.dispose();
    _future = initVideoPlayer();
  }

  @override
  void dispose() {
    _podPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: const AspectRatio(
              aspectRatio: 16 / 9,
              child: Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: LoadingIndicator(
                    indicatorType: Indicator.lineSpinFadeLoader,
                    colors: [AppColors.blue],
                  ),
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return PodVideoPlayer(
            controller: _podPlayerController,
            podProgressBarConfig: const PodProgressBarConfig(
              padding: EdgeInsets.symmetric(horizontal: 2),
              height: 2,
              backgroundColor: Colors.white,
              playingBarColor: AppColors.cream,
              circleHandlerColor: AppColors.cream,
            ),
            podPlayerLabels: const PodPlayerLabels(),
            alwaysShowProgressBar: false,
            videoAspectRatio: 16 / 9,
            onLoading: (context) {
              return const Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: LoadingIndicator(
                    indicatorType: Indicator.lineSpinFadeLoader,
                    colors: [AppColors.blue],
                  ),
                ),
              );
            },
          );
        }

        return const Center(
          child: Text("Failed to load video"),
        );
      },
    );
  }
}
