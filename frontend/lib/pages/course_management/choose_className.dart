import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/pages/course_management/manage_class.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/my_textfield.dart';

class ChooseClassName extends StatefulWidget {
  const ChooseClassName({super.key});

  @override
  State<ChooseClassName> createState() => _ChooseClassNameState();
}

class _ChooseClassNameState extends State<ChooseClassName> {
  //Services
  CourseService courseServices = CourseService();

  //Controllers
  final TextEditingController _classNameController = TextEditingController();

  //Focus Node
  final FocusNode _classNameFocusNode = FocusNode();

  //Variables
  bool _isNameEmpty = true;

  @override
  void initState() {
    super.initState();
    _classNameFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _classNameController.dispose();
    _classNameFocusNode.dispose();
    super.dispose();
  }

  Future<String> createNewCourse() async {
    try {
      var data = {
        "courseName": _classNameController.text,
        "description": jsonEncode([
          {"insert": "\n"}
        ]),
        "category": [],
        "students": 0,
        "projectNum": 0,
        "isPublic": false,
        "projectDescription": jsonEncode([
          {"insert": "\n"}
        ]),
        "thumbnail": "",
        "price": 0,
        "author":
            FirebaseAuth.instance.currentUser!.displayName ?? "Mindify Member",
        "authorId": FirebaseAuth.instance.currentUser!.uid,
        "duration": "",
        "lessonNum": 0,
      };
      String result = await courseServices.createCourse(data);

      return result;
    } catch (e) {
      log("Error creating course: $e");
      throw Exception("Failed to create course");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.ghostWhite,
      bottomSheet: Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cream,
            disabledForegroundColor: AppColors.lightGrey,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.3,
              vertical: 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _isNameEmpty
              ? null
              : () async {
                  String newCourseId = await createNewCourse();

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ManageClass(
                        courseId: newCourseId,
                        isEditing: false,
                      ),
                    ),
                  );
                },
          child: Text(
            "Create class",
            style: TextStyle(
              color: _isNameEmpty ? AppColors.lightGrey : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "New class",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.ghostWhite,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Start by giving your class a name.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.largeVertical,
              TextField(
                focusNode: _classNameFocusNode,
                controller: _classNameController,
                decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.blue,
                      width: 2,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.blue,
                      width: 2,
                    ),
                  ),
                ),
                cursorColor: AppColors.blue,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      _isNameEmpty = false;
                    });
                  } else {
                    setState(() {
                      _isNameEmpty = true;
                    });
                  }
                },
              ),
              AppSpacing.smallVertical,
              const Align(
                alignment: Alignment.topRight,
                child: Text(
                  'You can change this later*',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.lightGrey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
