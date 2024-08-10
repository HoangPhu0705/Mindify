// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/course_pages/courses_page.dart';
import 'package:frontend/pages/discover_page.dart';
import 'package:frontend/pages/user_information/view_profile_tabs/profile_page.dart';
import 'package:frontend/pages/search_page.dart';
import 'package:frontend/utils/colors.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  List<PersistentTabConfig> _tabs() => [
        PersistentTabConfig(
          screen: const DiscoverPage(),
          item: ItemConfig(
            icon: const Icon(CupertinoIcons.paperplane),
            activeColorSecondary: AppColors.cream,
            activeForegroundColor: AppColors.cream,
            inactiveForegroundColor: Colors.white,
            title: "Discover",
            textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
        ),
        PersistentTabConfig(
          screen: const SearchPage(),
          item: ItemConfig(
            icon: const Icon(CupertinoIcons.search),
            activeColorSecondary: AppColors.cream,
            activeForegroundColor: AppColors.cream,
            inactiveForegroundColor: Colors.white,
            title: "Search",
            textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
        ),
        PersistentTabConfig(
          screen: MyCoursePage(),
          item: ItemConfig(
            icon: const Icon(CupertinoIcons.play_circle),
            activeColorSecondary: AppColors.cream,
            activeForegroundColor: AppColors.cream,
            inactiveForegroundColor: Colors.white,
            title: "My Courses",
            textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
        ),
        PersistentTabConfig(
          screen: ProfilePage(
            bottom_nav_controller: _controller,
          ),
          item: ItemConfig(
            icon: const Icon(Icons.account_circle_outlined),
            activeColorSecondary: AppColors.cream,
            activeForegroundColor: AppColors.cream,
            inactiveForegroundColor: Colors.white,
            title: "Profile",
            textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) => PersistentTabView(
        tabs: _tabs(),
        controller: _controller,
        navBarBuilder: (navBarConfig) => Style1BottomNavBar(
          navBarDecoration: NavBarDecoration(
            color: AppColors.deepSpace,
          ),
          navBarConfig: navBarConfig,
        ),
      );
}
