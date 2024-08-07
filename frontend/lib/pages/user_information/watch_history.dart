import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/course_pages/course_detail.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/services/functions/ConnectivityService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:getwidget/getwidget.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

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
  late ConnectivityService connectivityService;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    userId = userService.getUserId();
    future = _fetchWatchedHistories();
    connectivityService = ConnectivityService();
  }

  @override
  void dispose() {
    connectivityService.dispose();
    super.dispose();
  }

  Future<void> _fetchWatchedHistories() async {
    try {
      final histories = await userService.getWatchedHistories(userId);
      watchedHistories = histories;
    } catch (e) {
      log(e.toString());
    }
  }

  void _onRefresh() async {
    setState(() {
      future = _fetchWatchedHistories();
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ghostWhite,
      appBar: AppBar(
        backgroundColor: AppColors.ghostWhite,
        surfaceTintColor: AppColors.ghostWhite,
        centerTitle: true,
        title: const Text(
          "Watch History",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SmartRefresher(
        onLoading: _onLoading,
        onRefresh: _onRefresh,
        controller: _refreshController,
        child: !connectivityService.isConnected
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      size: 100,
                      color: AppColors.blue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "You are offline",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .collection('watchedHistories')
                            .orderBy("timestamp", descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          return FutureBuilder(
                            future: _fetchWatchedHistories(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: MyLoading(
                                      width: 30,
                                      height: 30,
                                      color: AppColors.deepBlue),
                                );
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: watchedHistories.length,
                                itemBuilder: (context, index) {
                                  final history = watchedHistories[index];
                                  return Column(
                                    children: [
                                      GFListTile(
                                        onTap: () {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .push(
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                            return CourseDetail(
                                                courseId: history['courseId'],
                                                userId: userId);
                                          }));
                                        },
                                        avatar: GFImageOverlay(
                                          width: 125,
                                          height: 70,
                                          image: NetworkImage(
                                              history['thumbnail']),
                                          colorFilter: ColorFilter.mode(
                                            Colors.black.withOpacity(0.1),
                                            BlendMode.darken,
                                          ),
                                          child: const Icon(
                                            Icons.play_circle,
                                            size: 34,
                                            color: Colors.white,
                                          ),
                                        ),
                                        title: Text(
                                          history['title'],
                                          style: const TextStyle(
                                            fontFamily: "Poppins",
                                            fontWeight: FontWeight.w600,
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                        ),
                                        subTitle: Text(history['authorName']),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
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
                  ],
                ),
              ),
      ),
    );
  }
}
