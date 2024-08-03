import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/user_information/edit_profile.dart';
import 'package:frontend/pages/user_information/reminder_setup.dart';
import 'package:frontend/services/functions/ReminderService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/my_loading.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

//refactor this code
class _SettingPageState extends State<SettingPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  ReminderService reminderService = ReminderService();
  final dayName = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursdat',
    'Friday',
    'Saturday'
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  String getReminderText(String reminderDay) {
    DateTime now = DateTime.now();
    int currentDayIndex = now.weekday %
        7; // Monday is 1, Sunday is 7 in Dart. We convert it to 0-6.
    int reminderDayIndex = dayName.indexOf(reminderDay);
    int difference = (reminderDayIndex - currentDayIndex) % 7;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else {
      return '$difference days left';
    }
  }

  Future<void> _deleteReminder(String reminderId) async {
    try {
      await reminderService.deleteReminder(user!.uid, reminderId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reminder deleted successfully"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete reminder: $e"),
        ),
      );
    }
  }

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
                  _showReminderBottomSheet();
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

  void _showReminderBottomSheet() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.95,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.ghostWhite,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(10),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                  const Text(
                    "Learning Reminders",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                ],
              ),
              const Divider(),
              AppSpacing.mediumVertical,
              const Text(
                "Get reminders to watch your classes",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppSpacing.mediumVertical,
              StreamBuilder<QuerySnapshot>(
                stream: reminderService.getUserRemindersStream(user),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: MyLoading(
                        width: 30,
                        height: 30,
                        color: AppColors.deepBlue,
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error loading reminders.'),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Image.asset("assets/images/reminders.png"),
                          AppSpacing.mediumVertical,
                          const Text(
                            textAlign: TextAlign.center,
                            "We'll send a helpful reminder to watch your classes",
                            style: TextStyle(fontSize: 14),
                          ),
                          AppSpacing.mediumVertical,
                          ElevatedButton(
                            style: AppStyles.secondaryButtonStyle,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ReminderSetupPage(),
                                ),
                              );
                            },
                            child: const Text('Add Reminder'),
                          ),
                          AppSpacing.mediumVertical,
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final reminder = snapshot.data!.docs[index];

                          return Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${reminder['day']} at ${reminder['time']}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      getReminderText(reminder['day']),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.deepBlue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                AppSpacing.mediumVertical,
                                Text(
                                  "Take ${reminder['day']} to hone your skills!. We'll send you a little nudge to come watch your courses.",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () {
                                      _deleteReminder(reminder.id);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      AppSpacing.mediumVertical,
                      ElevatedButton(
                        style: AppStyles.secondaryButtonStyle,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReminderSetupPage(),
                            ),
                          );
                        },
                        child: const Text('Add Reminder'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
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
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
