// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'dart:developer';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:form_page_view/enum/progress_enum.dart';
import 'package:form_page_view/models/form_page_model.dart';
import 'package:form_page_view/models/form_page_style.dart';
import 'package:frontend/utils/colors.dart';
import 'package:form_page_view/form_page_view.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/widgets/instructor_signup_forms/category_selection.dart';

class InstructorSignUp extends StatefulWidget {
  const InstructorSignUp({super.key});

  @override
  State<InstructorSignUp> createState() => InstructorSignUpState();
}

class InstructorSignUpState extends State<InstructorSignUp> {
  //Variables
  List<String> _categories = [
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
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
            setState(() {
              _currentCategory = value;
            });
          },
        ),
      ),
      FormPageModel(
        formKey: formKeyPage2,
        textButton: 'Continue',
        isButtonEnabled: true,
        body: Form(
          key: formKeyPage2,
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
            ],
          ),
        ),
      ),
      FormPageModel(
        formKey: formKeyPage3,
        textButton: 'Finish',
        body: Form(
          key: formKeyPage3,
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
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
        centerTitle: true,
        title: Text(
          "Mindify.",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.blue,
          ),
        ),
        backgroundColor: AppColors.deepSpace,
      ),
      body: FormPageView(
        showAppBar: false,
        progress: ProgressIndicatorType.linear,
        pages: pages,
        onFormSubmitted: () {
          log('$_currentCategory');
          log('First Name: ${firstNameController.text}');
          log('Last Name: ${lastNameController.text}');
          log('Email: ${emailController.text}');
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
    );
  }
}
