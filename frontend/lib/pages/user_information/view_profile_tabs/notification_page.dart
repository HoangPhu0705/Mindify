import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/functions/ConnectivityService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  late ConnectivityService _connectivityService;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _connectivityService = ConnectivityService();
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

  void _onRefresh() async {
    setState(() {});
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
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
          'Notifications',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      body: SmartRefresher(
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        controller: _refreshController,
        child: !_connectivityService.isConnected
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
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('notifications')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("You have no notifications"),
                    );
                  }

                  var notifications = snapshot.data!.docs;

                  return ListView.separated(
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      var notification = notifications[index];
                      var timestamp =
                          (notification['timestamp'] as Timestamp).toDate();
                      var timeAgo = timeago.format(timestamp);

                      return ListTile(
                        leading: const Icon(
                          Icons.notifications,
                          color: AppColors.deepBlue,
                        ),
                        title: Text(notification['title']),
                        subtitle: Text(
                          notification['body'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          timeAgo,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
