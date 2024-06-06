// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/courses_page.dart';
import 'package:frontend/pages/discover_page.dart';
import 'package:frontend/pages/user_information/profile_page.dart';
import 'package:frontend/pages/search_page.dart';
import 'package:frontend/utils/colors.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});
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
          screen: const MyCoursePage(),
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
          screen: const ProfilePage(),
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
        navBarBuilder: (navBarConfig) => Style1BottomNavBar(
          navBarDecoration: NavBarDecoration(
            color: AppColors.deepSpace,
          ),
          navBarConfig: navBarConfig,
        ),
      );
}
