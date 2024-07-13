import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/user_information/edit_profile.dart';
import 'package:frontend/utils/colors.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

//refactor this code
class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.ghostWhite,
        centerTitle: true,
        title: const Text(
          "Settings",
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.ghostWhite,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Profile"),
              _buildListTile(
                "Edit Profile",
                Icons.chevron_right_outlined,
                () {
                  //go to edit profile page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditProfile()),
                  );
                },
              ),
              const Divider(),
              _buildSectionTitle("Notification"),
              _buildListTileNotify(
                "Learning reminders",
                "Set aside time every week for learning",
                () {
                  log("notify");
                },
              ),
              const Divider(),
              _buildSectionTitle("About"),
              _buildListTile(
                "Terms of Service",
                Icons.chevron_right_outlined,
                () {},
              ),
              const Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Divider(),
              ),
              _buildListTile(
                "Privacy Policy",
                Icons.chevron_right_outlined,
                () {},
              ),
              const Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Divider(),
              ),
              _buildListTile(
                "Teacher Rules and Requirements",
                Icons.chevron_right_outlined,
                () {},
              ),
              const Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Divider(),
              ),
              _buildListTileDeleteAccount(
                "Delete Account",
                () {
                  log("Delete Account");
                },
              ),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, top: 15.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .bodyLarge!
            .copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildListTile(String title, IconData icon, VoidCallback onTap) {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: ListTile(
        splashColor: AppColors.ghostWhite,
        title: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.w400),
        ),
        trailing: Icon(icon),
        onTap: onTap,
      ),
    );
  }

  Widget _buildListTileNotify(
      String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 12),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge!,
      ),
      trailing: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.black,
              )),
          child: Text(
            "Manage",
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildListTileDeleteAccount(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge!,
      ),
      trailing: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.black,
              )),
          child: Text(
            "Delete my account",
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}
