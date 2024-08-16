// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/auth/sign_in.dart';
import 'package:frontend/pages/user_information/downloads.dart';
import 'package:frontend/pages/user_information/saved_classes.dart';
import 'package:frontend/pages/user_information/setting_page.dart';
import 'package:frontend/pages/user_information/view_profile_tabs/notification_page.dart';
import 'package:frontend/pages/user_information/view_profile_tabs/view_profile.dart';
import 'package:frontend/pages/user_information/watch_history.dart';
import 'package:frontend/services/functions/EnrollmentService.dart';
import 'package:frontend/services/functions/NotificationService.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/services/providers/UserProvider.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:provider/provider.dart';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatefulWidget {
  final PersistentTabController bottom_nav_controller;
  const ProfilePage({
    super.key,
    required this.bottom_nav_controller,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserService userService = UserService();
  EnrollmentService enrollmentService = EnrollmentService();
  String? userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userId = userService.getUserId();
      String displayName = userService.getUsername();
      Provider.of<UserProvider>(context, listen: false)
          .setDisplayName(displayName);
      String photoUrl = userService.getPhotoUrl();
      Provider.of<UserProvider>(context, listen: false).setPhotoUrl(photoUrl);
    });
  }

  Future<List<String>> getInfo() async {
    return await enrollmentService.getUserEnrollments(userId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ghostWhite,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.ghostWhite,
          ),
          child: Column(
            children: [
              Container(
                color: AppColors.deepBlue,
                padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 30.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotificationsPage(),
                              ),
                            );
                          },
                          child: Icon(
                            CupertinoIcons.bell,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        AppSpacing.mediumHorizontal,
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SettingPage(),
                              ),
                            );
                          },
                          child: Icon(
                            CupertinoIcons.gear,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.largeVertical,
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: Image(
                            image: NetworkImage(
                              context.watch<UserProvider>().photoUrl,
                            ),
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              return Text('Error loading image');
                            },
                          ).image,
                          radius: 30,
                        ),
                        AppSpacing.mediumHorizontal,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.watch<UserProvider>().displayName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewProfile(
                                      bottom_nav_controller:
                                          widget.bottom_nav_controller,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'View Profile',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                      color: AppColors.cream,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  decoration: BoxDecoration(
                    color: AppColors.ghostWhite,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.arrow_circle_down),
                        title: Text(
                          'Downloads',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(fontSize: 16),
                        ),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (context) => Downloads(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.bookmark_border_outlined),
                        title: Text(
                          'All saved Classes',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(fontSize: 16),
                        ),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SavedClasses(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.history),
                        title: Text(
                          'Watched History',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(fontSize: 16),
                        ),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WatchHistory(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Logout'),
                        onTap: signUserOut,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void signUserOut() async {
    final notificationService = NotificationService();
    await notificationService.deleteTokenFromDatabase();
    await FirebaseAuth.instance.signOut();
  }
}
