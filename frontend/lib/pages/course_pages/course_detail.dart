import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:frontend/widgets/video_player_view.dart';
import 'package:video_player/video_player.dart';

class CourseDetail extends StatefulWidget {
  const CourseDetail({super.key});

  @override
  State<CourseDetail> createState() => _CourseDetailState();
}

class _CourseDetailState extends State<CourseDetail> {
  late ChewieController _chewieController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.3,
              child: VideoPlayerView(
                url:
                    "https://www.shutterstock.com/shutterstock/videos/8848282/preview/stock-footage-sunset-time-lapse-of-busy-light-trail-traffic-with-kuala-lumpur-skyline-at-kuala-lumpur-city.webm",
                dataSourceType: DataSourceType.network,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
