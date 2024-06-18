// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:getwidget/getwidget.dart';

class SubmitProject extends StatefulWidget {
  const SubmitProject({super.key});

  @override
  State<SubmitProject> createState() => _SubmitProjectState();
}

class _SubmitProjectState extends State<SubmitProject> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            8, 8, 8, MediaQuery.of(context).size.height / 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Class projects",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSpacing.mediumVertical,
            SizedBox(
              height: 100.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: MediaQuery.of(context).size.width * 0.3,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            "https://pollthepeople.app/wp-content/uploads/2022/06/Figma-Design-Flow-Image.png"),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  );
                },
              ),
            ),
            AppSpacing.mediumVertical,
            const Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "Show All",
                style: TextStyle(
                  color: AppColors.deepBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            AppSpacing.mediumVertical,
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: BoxDecoration(
                color: AppColors.lighterGrey,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Project Instructions",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    AppSpacing.mediumVertical,
                    Text(
                      '''Create a YouTube video with all the tips and tricks implemented from this class.
Start with the thumbnail and title Work out the video concept
Record your video with clean audio 
Make a snappy edit
Add a call to action and engage with your audiencess
''',
                      maxLines: 7,
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppSpacing.mediumVertical,
                    const Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        "Show all",
                        style: TextStyle(
                          color: AppColors.deepBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
