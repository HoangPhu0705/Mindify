// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:getwidget/getwidget.dart';

class Downloads extends StatefulWidget {
  const Downloads({super.key});

  @override
  State<Downloads> createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.ghostWhite,
        centerTitle: true,
        title: Text(
          "Downloads",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListView.separated(
              separatorBuilder: (context, index) {
                return Divider();
              },
              shrinkWrap: true,
              itemCount: 3,
              itemBuilder: (context, index) {
                return GFListTile(
                  avatar: Icon(
                    Icons.play_circle_fill,
                    size: 40,
                  ),
                  title: Text(
                    "Working on the Timeline",
                    style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w500,
                        fontSize: 18),
                  ),
                  subTitle: Text(
                    "From Class: CapCut for Desktop: The Ultimate Video Editing Course for Reels and TikTok Creators",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(fontFamily: "Poppins"),
                  ),
                  icon: Icon(
                    Icons.download_for_offline_sharp,
                    size: 32,
                    color: AppColors.deepBlue,
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
