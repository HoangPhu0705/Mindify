// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/auth/sign_in.dart';
import 'package:frontend/pages/setting_page.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: AppColors.deepBlue,
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 30.0),
            child: Column(
              children: [
                Row(
                  //icon notification
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {},
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
                      backgroundImage: NetworkImage(
                          "https://avatar.iran.liara.run/public/boy"),
                      radius: 30,
                    ),
                    AppSpacing.mediumHorizontal,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phú Phan',
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                        Text(
                          'View Profile',
                          style:
                              Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: AppColors.cream,
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
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: ListView(
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
                    subtitle: Text('0 classes'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {},
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
                      // Handle All saved Classes tap
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
                    onTap: () {},
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
    );
  }
}
