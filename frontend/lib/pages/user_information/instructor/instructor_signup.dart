// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_page_view/enum/progress_enum.dart';
import 'package:form_page_view/models/form_page_model.dart';
import 'package:form_page_view/models/form_page_style.dart';
import 'package:frontend/utils/colors.dart';
import 'package:form_page_view/form_page_view.dart';
import 'package:frontend/utils/styles.dart';

class InstructorSignUp extends StatefulWidget {
  const InstructorSignUp({super.key});

  @override
  State<InstructorSignUp> createState() => InstructorSignUpState();
}

class InstructorSignUpState extends State<InstructorSignUp> {
  //Variables

  //Controllers
  final PageController _pageController = PageController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //Form keys
    final GlobalKey<FormState> formKeyPage1 = GlobalKey<FormState>();
    final GlobalKey<FormState> formKeyPage2 = GlobalKey<FormState>();
    final GlobalKey<FormState> formKeyPage3 = GlobalKey<FormState>();

    final List<FormPageModel> pages = [
      FormPageModel(
        formKey: formKeyPage1,
        title: 'Page 1',
        textButton: 'Next to page 2',
        buttonStyle: AppStyles.secondaryButtonStyle,
        isButtonEnabled: true,
        body: Form(
          key: formKeyPage1,
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              )
            ],
          ),
        ),
      ),
      FormPageModel(
        formKey: formKeyPage2,
        title: 'Page 2',
        textButton: 'Next to page 3',
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
        title: 'Page 3',
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
            log(_pageController.page.toString());
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
            );
          },
        ),
        backgroundColor: AppColors.deepSpace,
      ),
      body: SafeArea(
        child: FormPageView(
          showAppBar: false,
          progress: ProgressIndicatorType.linear,
          pages: pages,
          onFormSubmitted: () {
            log('Username: ${usernameController.text}');
            log('First Name: ${firstNameController.text}');
            log('Last Name: ${lastNameController.text}');
            log('Email: ${emailController.text}');
          },
          style: FormPageStyle(
            appBarBackgroundColor: AppColors.deepSpace,
            backgroundColor: AppColors.deepSpace,
            progressIndicatorBackgroundColor: Colors.white,
            buttonStyle: AppStyles.primaryButtonStyle,
            buttonTextStyle: const TextStyle(
              color: Colors.black,
            ),
            appBarElevation: 0,
          ),
          controller: _pageController,
        ),
      ),
    );
  }
}
