import 'package:flutter/material.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:getwidget/getwidget.dart';

class WatchHistory extends StatefulWidget {
  const WatchHistory({super.key});

  @override
  State<WatchHistory> createState() => _WatchHistoryState();
}

class _WatchHistoryState extends State<WatchHistory> {
  final userService = UserService();
  String userId = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userId = userService.getUserId();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.ghostWhite,
          centerTitle: true,
          title: Text(
            "Watch History",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: ListView.builder(
          itemCount: 3,
          itemBuilder: (context, index) {
            return Column(
              children: [
                GFListTile(
                  avatar: GFImageOverlay(
                    width: 125,
                    height: 70,
                    child: Icon(
                      Icons.play_circle,
                      size: 34,
                    ),
                    image: NetworkImage(
                        "https://static.skillshare.com/uploads/video/thumbnails/3d4e26f38f2cb702b655467f0be55771/448-252"),
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.1),
                      BlendMode.darken,
                    ),
                  ),
                  title: Text(
                    "CapCut for Desktop: The Ultimate Video Editing Course for Reels and TikTok Creators",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                  ),
                  subTitle: Text(
                    "Lisa Badot",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Divider(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
