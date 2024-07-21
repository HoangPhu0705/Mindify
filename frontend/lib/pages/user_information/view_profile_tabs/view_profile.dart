// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/pages/user_information/view_profile_tabs/achievements_tab.dart';
import 'package:frontend/pages/user_information/view_profile_tabs/follow_user_page.dart';
import 'package:frontend/pages/user_information/view_profile_tabs/profile_tab.dart';
import 'package:frontend/pages/user_information/view_profile_tabs/teaching_tab.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/services/providers/UserProvider.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:provider/provider.dart';

class ViewProfile extends StatefulWidget {
  const ViewProfile({super.key});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile>
    with SingleTickerProviderStateMixin {
  UserService userService = UserService();
  TabController? _tabController;
  int? followers;
  int? following;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      String displayName = userService.getUsername();
      Provider.of<UserProvider>(context, listen: false)
          .setDisplayName(displayName);
      String photoUrl = userService.getPhotoUrl();
      Provider.of<UserProvider>(context, listen: false).setPhotoUrl(photoUrl);
    });
    getUserData();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> getUserData() async {
    String userId = userService.getUserId();
    final userData = await userService.getUserData(userId);

    if (userData != null) {
        setState(() {
          followers = userData['followerNum'] ?? 0;
          following = userData['followingNum'] ?? 0;
        });
      }

  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.ghostWhite,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: BoxDecoration(
                color: AppColors.deepBlue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  CircleAvatar(
                    backgroundImage: Image(
                      image: NetworkImage(
                        context.watch<UserProvider>().photoUrl,
                      ),
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        return Text('Error loading image');
                      },
                    ).image,
                    radius: 40,
                  ),
                  AppSpacing.smallVertical,
                  Text(
                    context.watch<UserProvider>().displayName,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  //email
                  Text(
                    FirebaseAuth.instance.currentUser!.email!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => FollowersFollowingPage(
                                userId: userService.getUserId(),
                                tab: 0,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "$followers Followers •",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => FollowersFollowingPage(
                                userId: userService.getUserId(),
                                tab: 1, // Navigate to Following tab
                              ),
                            ),
                          );
                        },
                        child: Text(
                          " $following Following ",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              splashFactory: NoSplash.splashFactory,
              tabs: const [
                Tab(text: 'Profile'),
                Tab(text: 'Teaching'),
                Tab(text: 'Achievement'),
              ],
              labelStyle: TextStyle(
                color: AppColors.deepBlue,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              unselectedLabelColor: AppColors.deepBlue,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: AppColors.deepBlue,
              indicatorWeight: 3,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ProfileTab(),
                  TeachingTab(),
                  AchievementTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
