import 'dart:io';
import 'dart:developer';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerView extends StatefulWidget {
  final url;
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
  late ChewieController _chewieController;
  late Future<void> _future;

  Future<void> initVideoPlayer() async {
    await _videoPlayerController.initialize();
    setState(() {
      log(_videoPlayerController.value.aspectRatio.toString());
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        allowFullScreen: true,
        autoPlay: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.cream,
          handleColor: AppColors.cream,
          backgroundColor: AppColors.lightGrey,
          bufferedColor: AppColors.lightGrey,
        ),
        cupertinoProgressColors: ChewieProgressColors(
          playedColor: AppColors.cream,
          handleColor: AppColors.cream,
          backgroundColor: AppColors.lightGrey,
          bufferedColor: AppColors.lightGrey,
        ),
        autoInitialize: true,
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    switch (widget.dataSourceType) {
      case DataSourceType.network:
        _videoPlayerController =
            VideoPlayerController.networkUrl(Uri.parse(widget.url));
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
    // TODO: implement dispose
    super.dispose();
    _videoPlayerController.dispose();
    _chewieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        return Center(
          child: _videoPlayerController.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _videoPlayerController.value.aspectRatio,
                  child: Chewie(
                    controller: _chewieController,
                  ),
                )
              : const Padding(
                  padding: EdgeInsets.all(115.0),
                  child: LoadingIndicator(
                      indicatorType: Indicator.lineSpinFadeLoader,
                      colors: [AppColors.blue],
                      strokeWidth: 2,
                      backgroundColor: Colors.black,
                      pathBackgroundColor: Colors.black),
                ),
        );
      },
    );
  }
}
