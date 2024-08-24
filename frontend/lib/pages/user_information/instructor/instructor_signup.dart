// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:comment_tree/comment_tree.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:form_page_view/enum/progress_enum.dart';
import 'package:form_page_view/models/form_page_model.dart';
import 'package:form_page_view/models/form_page_style.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:form_page_view/form_page_view.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/toasts.dart';
import 'package:frontend/widgets/instructor_signup_forms/category_selection.dart';
import 'package:frontend/widgets/instructor_signup_forms/describe_class.dart';
import 'package:frontend/widgets/instructor_signup_forms/personal_detail.dart';
import 'package:frontend/widgets/instructor_signup_forms/sign_up_successfully.dart';
import 'package:image_picker/image_picker.dart';

class InstructorSignUp extends StatefulWidget {
  const InstructorSignUp({super.key});

  @override
  State<InstructorSignUp> createState() => InstructorSignUpState();
}

class InstructorSignUpState extends State<InstructorSignUp> {
  //Variables
  final List<String> _categories = [
    'Animation',
    'Culinary',
    'Drawing',
    'Film',
    'Graphic Design',
    'Illustration',
    'Photography',
    'Procreate',
    'Watercolor',
    'Programming',
    'Writing',
    'Other',
  ];
  String? _currentCategory;

  //Controllers
  final PageController _pageController = PageController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _countryNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _topicDescription = TextEditingController();
  String idCardPath = "";

  //Services
  UserService _userService = UserService();

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  void onIdCardChanged(String path) {
    setState(() {
      idCardPath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppColors.deepSpace,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    //Form keys

    final GlobalKey<FormState> formKeyPage1 = GlobalKey<FormState>();
    final GlobalKey<FormState> formKeyPage2 = GlobalKey<FormState>();
    final GlobalKey<FormState> formKeyPage3 = GlobalKey<FormState>();

    final List<FormPageModel> pages = [
      FormPageModel(
        formKey: formKeyPage1,
        textButton: 'Continue',
        body: CategorySelectionForm(
          formKey: formKeyPage1,
          categories: _categories,
          currentCategory: _currentCategory,
          onChanged: (String? value) {
            setState(
              () {
                _currentCategory = value;
              },
            );
          },
        ),
      ),
      FormPageModel(
        formKey: formKeyPage2,
        textButton: 'Continue',
        isButtonEnabled: true,
        body: PersonalDetail(
          formKey: formKeyPage2,
          firstNameController: _firstNameController,
          lastNameController: _lastNameController,
          phoneNumberController: _phoneNumberController,
          countryNameController: _countryNameController,
          dobController: _dobController,
          onIdCardSelected: onIdCardChanged,
        ),
      ),
      FormPageModel(
        formKey: formKeyPage3,
        textButton: 'Finish',
        body: DescribeClass(
          formKey: formKeyPage3,
          topicDescription: _topicDescription,
        ),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.deepSpace,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      CupertinoIcons.back,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      double? currentPage = _pageController.page;

                      if (currentPage == 0) {
                        Navigator.pop(context);
                      }

                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                  ),
                  Text(
                    "Mindify.",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blue,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FormPageView(
                showAppBar: false,
                progress: ProgressIndicatorType.linear,
                pages: pages,
                onFormSubmitted: () async {
                  if (idCardPath.isEmpty) {
                    showErrorToast(context, "Id card is required");
                    return;
                  }
                  File file = File(idCardPath);
                  if (!file.existsSync()) {
                    print("File does not exist at path: ${idCardPath}");
                    return;
                  }

                  FirebaseStorage storage = FirebaseStorage.instance;
                  Reference ref = storage.ref().child(
                      'idCards/card_${FirebaseAuth.instance.currentUser!.uid}');
                  await ref.putFile(file);
                  String idCardImage = await ref.getDownloadURL();

                  var data = {
                    'user_id': FirebaseAuth.instance.currentUser!.uid,
                    'user_email': FirebaseAuth.instance.currentUser!.email,
                    'category': _currentCategory,
                    'firstName': _firstNameController.text,
                    'lastName': _lastNameController.text,
                    'phoneNumber': _phoneNumberController.text,
                    'countryName': _countryNameController.text,
                    'dob': _dobController.text,
                    'topicDescription': _topicDescription.text,
                    'status': 'Pending',
                    'isApproved': false,
                    'idCard': idCardImage,
                  };
                  await _userService.sendInstructorRequest(data);
                  await _userService.updateUserRequestStatus(
                      FirebaseAuth.instance.currentUser!.uid, true);
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => SendSuccessfully(),
                    ),
                  );
                },
                style: FormPageStyle(
                  appBarBackgroundColor: AppColors.deepSpace,
                  backgroundColor: AppColors.deepSpace,
                  progressIndicatorBackgroundColor: AppColors.ghostWhite,
                  progressIndicatorColor: AppColors.cream,
                  buttonStyle: AppStyles.primaryButtonStyle,
                  buttonTextStyle: const TextStyle(
                    color: Colors.black,
                  ),
                ),
                controller: _pageController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
