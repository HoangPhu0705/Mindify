import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:pod_player/pod_player.dart';
import 'dart:io';

class VideoPlayerView extends StatefulWidget {
  final String url;
  final DataSourceType dataSourceType;
  final int currentTime;
  final Function onVideoEnd;

  const VideoPlayerView({
    super.key,
    required this.url,
    required this.dataSourceType,
    required this.currentTime,
    required this.onVideoEnd,
  });

  @override
  State<VideoPlayerView> createState() => VideoPlayerViewState();
}

class VideoPlayerViewState extends State<VideoPlayerView> {
  late PodPlayerController _podPlayerController;
  late Future<void> _future;

  Future<void> initVideoPlayer() async {
    PlayVideoFrom playVideoFrom;
    if (widget.dataSourceType == DataSourceType.file) {
      log("file");
      playVideoFrom = PlayVideoFrom.file(File(widget.url));
    } else {
      log("network");
      playVideoFrom = PlayVideoFrom.network(widget.url);
    }

    _podPlayerController = PodPlayerController(
      playVideoFrom: playVideoFrom,
      podPlayerConfig: const PodPlayerConfig(
        autoPlay: true,
        videoQualityPriority: [1080, 720, 360],
      ),
    );

    await _podPlayerController.initialise();
    log("vo lai");
    seekToPeriod(Duration(seconds: widget.currentTime));
  }

  @override
  void initState() {
    super.initState();
    _future = initVideoPlayer();
    _podPlayerController.addListener(lessonEnded);
  }

  @override
  void dispose() {
    removePodListener();
    _podPlayerController.dispose();
    super.dispose();
  }

  Future<void> goToVideo(String url) async {
    await _podPlayerController.changeVideo(
      playVideoFrom: PlayVideoFrom.network(url),
    );
   
    removePodListener();
    addPodListener();
  }

  Future<void> goToDownloadedVideo(String filePath) async {
    await _podPlayerController.changeVideo(
      playVideoFrom: PlayVideoFrom.file(File(filePath)),
    );
  }

  bool islooping() {
    bool isLooping = _podPlayerController.isVideoLooping;
    return isLooping;
  }

  int getCurrentTime() {
    int currentTime = _podPlayerController.currentVideoPosition.inSeconds;
    return currentTime;
  }

  Future<void> seekToPeriod(Duration duration) async {
    await _podPlayerController.videoSeekTo(duration);
  }

  bool lessonEnded() {
    if (_podPlayerController.videoPlayerValue != null &&
        _podPlayerController.videoPlayerValue!.isInitialized) {
      final videoPosition = _podPlayerController.videoPlayerValue!.position;
      final videoDuration = _podPlayerController.videoPlayerValue!.duration;

      log('Current Position: $videoPosition, Duration: $videoDuration');
      if (videoPosition >= videoDuration - Duration(milliseconds: 900)) {
        removePodListener();
        log('Lesson Ended');

        widget.onVideoEnd(widget.url);

        return true;
      }
    }

    return false;
  }

  void removePodListener() {
    _podPlayerController.removeListener(lessonEnded);
  }

  void addPodListener() {
    _podPlayerController.addListener(lessonEnded);
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
