import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:video_player/video_player.dart';
import 'package:pod_player/pod_player.dart';


class VideoPlayerView extends StatefulWidget {
  final String url;
  final DataSourceType dataSourceType;
  int current;
  final Function(int) onTimeUpdate;

  VideoPlayerView({
    super.key,
    required this.url,
    required this.dataSourceType,
    required this.current,
    required this.onTimeUpdate,
  });

  @override
  State<VideoPlayerView> createState() => VideoPlayerViewState();
}

class VideoPlayerViewState extends State<VideoPlayerView> {
  late PodPlayerController _podPlayerController;
  late Future<void> _future;
  Timer? _timer;
  bool _isDisposed = false;

  Future<void> initVideoPlayer() async {
    _podPlayerController = PodPlayerController(
      playVideoFrom: PlayVideoFrom.network(widget.url),
      podPlayerConfig: const PodPlayerConfig(
        autoPlay: true,
        isLooping: false,
        videoQualityPriority: [360, 720],
      ),
    )..initialise();
    _podPlayerController.addListener(_handlePositionChange);
  }

  @override
  void initState() {
    super.initState();
    _future = initVideoPlayer();
    _loadAndSeekToStartTime();
    _startTimer();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    _podPlayerController.dispose();
    super.dispose();
  }

  void goToVideo(String url) {
    _podPlayerController.changeVideo(
      playVideoFrom: PlayVideoFrom.network(url),
    );
  }

  Future<void> _loadAndSeekToStartTime() async {
    if (widget.current != 0) {
      _podPlayerController.videoSeekTo(Duration(seconds: widget.current.toInt()));
    }
  }

  void _handlePositionChange() {
    setState(() {
      widget.current = _podPlayerController.videoPlayerValue!.position.inSeconds;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      if (!_isDisposed) {
        widget.onTimeUpdate(widget.current);
      }
    });
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
