import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';

class AchievementTab extends StatefulWidget {
  const AchievementTab({super.key});

  @override
  State<AchievementTab> createState() => _AchievementTabState();
}

class _AchievementTabState extends State<AchievementTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Achievements',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium!
                  .copyWith(color: Colors.black),
            ),
            AppSpacing.largeVertical,
            Text(
              'Certificates',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: Colors.black,
                    fontSize: 18,
                  ),
            ),
            AppSpacing.smallVertical,
            Text(
              "Earn a class certificate by completing a class and submitting a project",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            AppSpacing.mediumVertical,
            DottedBorder(
              strokeWidth: 2,
              color: AppColors.lightGrey,
              strokeCap: StrokeCap.round,
              borderType: BorderType.Rect,
              dashPattern: [8, 4],
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "You haven't earned a certificate yet.",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    AppSpacing.mediumVertical,
                    Text(
                      "Complete a class and submit a project to earn your first class certificate.",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    AppSpacing.mediumVertical,
                    ElevatedButton(
                      onPressed: () {},
                      style: AppStyles.secondaryButtonStyle,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Find a class"),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
