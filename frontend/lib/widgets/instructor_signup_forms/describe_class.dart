import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';

class DescribeClass extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController topicDescription;

  const DescribeClass({
    super.key,
    required this.formKey,
    required this.topicDescription,
  });

  @override
  State<DescribeClass> createState() => _DescribeClassState();
}

class _DescribeClassState extends State<DescribeClass> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            AppSpacing.largeVertical,
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                "3.",
                style: TextStyle(
                  color: AppColors.cream,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            const Text(
              "In 3-5 sentences, tell us about you and your class topic?*",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            AppSpacing.mediumVertical,
            Text(
              "Please be specific about your class's topic. If the topic is unclear, the application will be denied. If the topic is vague or violates our guidelines, the application will be denied",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[200],
                fontWeight: FontWeight.w400,
              ),
            ),
            AppSpacing.mediumVertical,
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                '''Example do's:\n"I would like to teach how to make simple dishes using basic ingredients."\n"I would like to teach basic programming using Python."''',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[200],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            AppSpacing.mediumVertical,
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                '''Example don'ts:\n"I would like to teach how to make money online."\n"I would like to teach trending topics.",''',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[200],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            AppSpacing.mediumVertical,

            // Text field for user to describe their class
            TextFormField(
              maxLines: 10,
              controller: widget.topicDescription,
              decoration: const InputDecoration(
                hintText: "I would like to teach...",
                hintStyle: TextStyle(
                  color: AppColors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.cream,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.cream,
                    width: 2,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please describe your class';
                }
                return null;
              },
              onChanged: (value) {
                widget.topicDescription.text = value;

                log(widget.topicDescription.text);
              },
              cursorColor: AppColors.cream,
              textInputAction: TextInputAction.done,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
