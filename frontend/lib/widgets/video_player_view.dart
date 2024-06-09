import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
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

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 16 / 9,
      allowFullScreen: true,
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
    return Chewie(
      controller: _chewieController,
    );
  }
}
