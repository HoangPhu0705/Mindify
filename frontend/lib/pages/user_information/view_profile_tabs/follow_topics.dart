import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/constants.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/utils/toasts.dart';
import 'package:getwidget/colors/gf_color.dart';
import 'package:getwidget/components/image/gf_image_overlay.dart';
import 'package:selectable_container/selectable_container.dart';

class FollowSkills extends StatefulWidget {
  const FollowSkills({super.key});

  @override
  State<FollowSkills> createState() => _FollowSkillsState();
}

class _FollowSkillsState extends State<FollowSkills> {
  //Services
  UserService userService = UserService();
  List<String> categories = [];
  List<String> categoryImage = [];

  //Variables
  String? username;
  List<String> skillsSelected = [];

  @override
  void initState() {
    super.initState();
    username = userService.getUsername();
    categories = AppConstants.categories;
    categoryImage = AppConstants.categoryImage;
  }

  Future<void> updateFollowTopic(var data) async {
    String uid = userService.getUserId();

    await userService.updateUserFollowedTopics(uid, data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.deepSpace,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              offset: const Offset(0, -1),
            ),
          ],
        ),
        height: MediaQuery.of(context).size.height * 0.1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppSpacing.mediumHorizontal,
            Expanded(
              child: TextButton(
                style: skillsSelected.isEmpty
                    ? AppStyles.disabledButton
                    : AppStyles.primaryButtonStyle,
                onPressed: skillsSelected.isEmpty
                    ? null
                    : () async {
                        await updateFollowTopic(skillsSelected);

                        if (mounted) {
                          Navigator.pop(context);
                        }
                      },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Get Started",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.ghostWhite,
        surfaceTintColor: AppColors.ghostWhite,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.ghostWhite,
          ),
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Hey $username, ",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),
              ),
              const Text(
                "Select topics that interest you and we'll make class recommendations for you",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.9,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 0,
                    childAspectRatio: 1.8,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    String category = categories[index];
                    String image = categoryImage[index];
                    bool isSelected = skillsSelected.contains(category);
                    return buildTopicContainer(
                      category,
                      image,
                      isSelected,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextContentOfContainer(String category, String image) {
    return GFImageOverlay(
      borderRadius: BorderRadius.circular(8),
      height: 80,
      width: 160,
      image: AssetImage(image),
      boxFit: BoxFit.cover,
      colorFilter: ColorFilter.mode(
        Colors.black.withOpacity(0.3),
        BlendMode.darken,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 5, bottom: 5),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            category,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTopicContainer(String category, String image, bool isSelected) {
    return SelectableContainer(
      selectedBorderColor: AppColors.cream,
      unselectedBorderColor: AppColors.ghostWhite,
      iconAlignment: Alignment.topRight,
      icon: Icons.check_circle_outline,
      unselectedIcon: Icons.radio_button_unchecked,
      elevation: 0,
      iconColor: Colors.white,
      iconSize: 24,
      selectedBackgroundColorIcon: Colors.transparent,
      unselectedBackgroundColorIcon: Colors.transparent,
      unselectedBorderColorIcon: Colors.transparent,
      selectedBorderColorIcon: Colors.transparent,
      unselectedOpacity: 0.8,
      selectedOpacity: 1,
      topIconPosition: 12,
      rightIconPosition: 12,
      selected: isSelected,
      opacityAnimationDuration: 300,
      child: buildTextContentOfContainer(
        category,
        image,
      ),
      onValueChanged: (newValue) {
        setState(() {
          if (newValue) {
            if (skillsSelected.length < 5) {
              skillsSelected.add(category);
            } else {
              // Show a message or feedback to the user
              showErrorToast(
                context,
                'You can only select 5 skills at a time.',
              );
            }
          } else {
            skillsSelected.remove(category);
          }
        });
      },
    );
  }
}
