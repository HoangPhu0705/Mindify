// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/change_passwordField.dart';
import 'package:frontend/widgets/my_textfield.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  //Focus node
  final passwordFocusNode = FocusNode();
  final newPasswordFocusNode = FocusNode();

  var _isObsecured;

  @override
  void initState() {
    // TODO: implement initState
    _isObsecured = true;
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    passwordFocusNode.dispose();
    newPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: AppColors.ghostWhite,
          centerTitle: true,
          title: const Text(
            "Edit Profile",
            style: TextStyle(fontSize: 20),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Done",
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: AppColors.deepBlue,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                    "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png"),
              ),
              AppSpacing.largeVertical,
              Container(
                padding: EdgeInsets.all(24),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: Column(
                  children: [
                    _buildSection("Change Username"),
                    Form(
                      child: TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightGrey),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.blue),
                          ),
                          hintText: "Enter your username",
                          hintStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColors.lightGrey,
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.mediumVertical,
                    _buildSection("Change Password"),
                    Form(
                      child: Column(
                        children: [
                          ChangePasswordField(
                              obsecure: _isObsecured,
                              title: "Current password"),
                          AppSpacing.mediumVertical,
                          ChangePasswordField(
                              obsecure: _isObsecured, title: "New password"),
                          AppSpacing.mediumVertical,
                          ChangePasswordField(
                              obsecure: _isObsecured,
                              title: "Confirm new password"),
                          AppSpacing.mediumVertical,
                          ElevatedButton(
                            onPressed: () {},
                            style: AppStyles.secondaryButtonStyle,
                            child: Text("Change Password"),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Row(
      children: [
        Text(
          "$title:",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
