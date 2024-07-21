import 'package:flutter/material.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:frontend/utils/colors.dart';
import 'package:skeleton_loader/skeleton_loader.dart';

class FollowersFollowingPage extends StatefulWidget {
  final String userId;
  final int tab;

  FollowersFollowingPage({required this.userId, this.tab = 0});

  @override
  State<FollowersFollowingPage> createState() => _FollowersFollowingPageState();
}

class _FollowersFollowingPageState extends State<FollowersFollowingPage> {
  final UserService userService = UserService();
  late Future<Map<String, List<String>>> _userDataFuture;
  String displayName = 'Loading...'; // Initialize with a default value

  @override
  void initState() {
    super.initState();
    _userDataFuture = _initializeData();
  }

  Future<Map<String, List<String>>> _initializeData() async {
    try {
      final data = await userService.getAvatarAndDisplayName(widget.userId);
      setState(() {
        displayName = data?['displayName'] ?? 'Unknown'; // Update displayName
      });
      
      final followersFuture = _fetchFollowers(widget.userId);
      final followingFuture = _fetchFollowing(widget.userId);

      final followers = await followersFuture;
      final following = await followingFuture;

      return {
        'followers': followers,
        'following': following,
      };
    } catch (e) {
      print("Error initializing data: $e");
      return {
        'followers': [],
        'following': [],
      };
    }
  }

  Future<List<String>> _fetchFollowers(String userId) async {
    try {
      final userDoc = await userService.getUserInfoById(userId);
      if (userDoc != null && userDoc['followerUser'] != null) {
        return List<String>.from(userDoc['followerUser']);
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching followers: $e");
      return [];
    }
  }

  Future<List<String>> _fetchFollowing(String userId) async {
    try {
      final userDoc = await userService.getUserInfoById(userId);
      if (userDoc != null && userDoc['followingUser'] != null) {
        return List<String>.from(userDoc['followingUser']);
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching following: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.tab,
      child: Scaffold(
        appBar: AppBar(
          title: Text(displayName),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Followers'),
              Tab(text: 'Following'),
            ],
          ),
        ),
        body: FutureBuilder<Map<String, List<String>>>(
          future: _userDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SkeletonLoader(
                  builder: ListView.builder(
                    itemCount: 5, // Adjust based on expected number of items
                    itemBuilder: (context, index) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey.shade300,
                      ),
                      title: Container(
                        color: Colors.grey.shade300,
                        height: 16,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error loading data"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No data found"));
            }

            final followers = snapshot.data!['followers']!;
            final following = snapshot.data!['following']!;

            return TabBarView(
              children: [
                _buildUserList(followers),
                _buildUserList(following),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserList(List<String> userIds) {
    return ListView.builder(
      itemCount: userIds.length,
      itemBuilder: (context, index) {
        final userId = userIds[index];
        return FutureBuilder<Map<String, dynamic>?>(
          future: userService.getAvatarAndDisplayName(userId),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade300,
                ),
                title: Container(
                  color: Colors.grey.shade300,
                  height: 16,
                  width: double.infinity,
                ),
              );
            }
            if (userSnapshot.hasError || !userSnapshot.hasData) {
              return ListTile(
                title: Text('Error fetching user info'),
              );
            }
            final user = userSnapshot.data!;
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user['photoUrl']),
              ),
              title: Text(user['displayName']),
            );
          },
        );
      },
    );
  }
}
