import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/course_pages/course_detail.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:getwidget/getwidget.dart';

class WatchHistory extends StatefulWidget {
  const WatchHistory({super.key});

  @override
  State<WatchHistory> createState() => _WatchHistoryState();
}

class _WatchHistoryState extends State<WatchHistory> {
  final userService = UserService();
  String userId = '';
  List<dynamic> watchedHistories = [];
  late Future<void> future;

  @override
  void initState() {
    super.initState();
    userId = userService.getUserId();
    future = _fetchWatchedHistories();
  }

  Future<void> _fetchWatchedHistories() async {
    try {
      final histories = await userService.getWatchedHistories(userId);
              watchedHistories = histories;

    } catch (e) {
      log(e.toString());
    }
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
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('watchedHistories').orderBy("timestamp", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
// List<DocumentSnapshot> histories = snapshot.data!.docs;
              return FutureBuilder(
                future: _fetchWatchedHistories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting){
                    return MyLoading(width: 30, height: 30, color: AppColors.deepBlue);
                  }


                  return ListView.builder(
                    itemCount: watchedHistories.length,
                    itemBuilder: (context, index) {
                      final history = watchedHistories[index];
                      return Column(
                        children: [
                          GFListTile(
                            onTap: () {
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(builder: (context) {
                                  return CourseDetail(courseId: history['courseId'], userId: userId);
                                })
                              );
                            },
                            avatar: GFImageOverlay(
                              width: 125,
                              height: 70,
                              child: Icon(
                                Icons.play_circle,
                                size: 34,
                              ),
                              image: NetworkImage(history['thumbnail']),
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.1),
                                BlendMode.darken,
                              ),
                            ),
                            title: Text(
                              history['title'],
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                            ),
                            subTitle: Text(history['authorName']),
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
                  );
                },
              );
            }),
      ),
    );
  }
}
