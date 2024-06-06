// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/services/providers/UserProvider.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/utils/toasts.dart';
import 'package:frontend/widgets/bottom_sheet/image_option.dart';
import 'package:frontend/widgets/change_passwordField.dart';
import 'package:frontend/widgets/my_textfield.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  //Services
  final UserService _userService = UserService();

  //Controllers
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  //Focus node
  final passwordFocusNode = FocusNode();
  final newPasswordFocusNode = FocusNode();

  //key
  final GlobalKey<FormState> _changePasswordKey = GlobalKey<FormState>();

  var _isObsecured;

  @override
  void initState() {
    _isObsecured = true;
    super.initState();
    _usernameController.text = _userService.getUsername();
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
            GestureDetector(
              onTap: () async {
                var newName = _usernameController.text;
                await _userService.updateUsername(newName);
                Provider.of<UserProvider>(context, listen: false)
                    .setDisplayName(newName);

                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Done",
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: AppColors.deepBlue,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  showImageOptionModalBottomSheet(context);
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      NetworkImage("https://avatar.iran.liara.run/public/boy"),
                ),
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
                      key: _changePasswordKey,
                      child: Column(
                        children: [
                          ChangePasswordField(
                              controller: _passwordController,
                              obsecure: _isObsecured,
                              title: "Current password"),
                          AppSpacing.mediumVertical,
                          ChangePasswordField(
                              controller: _newPasswordController,
                              obsecure: _isObsecured,
                              title: "New password"),
                          AppSpacing.mediumVertical,
                          ChangePasswordField(
                              controller: _confirmNewPasswordController,
                              obsecure: _isObsecured,
                              title: "Confirm new password"),
                          AppSpacing.mediumVertical,
                          ElevatedButton(
                            onPressed: () {
                              if (_changePasswordKey.currentState!.validate()) {
                                changePassword();
                              }
                            },
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

  Future<void> changePassword() async {
    String currentPassword = _passwordController.text;
    String newPassword = _newPasswordController.text;
    String confirmNewPassword = _confirmNewPasswordController.text;

    if (newPassword != confirmNewPassword) {
      showErrorToast(context, "Passwords do not match");
    } else {
      try {
        String response =
            await _userService.changePassword(currentPassword, newPassword);
        if (response.isEmpty) {
          showSuccessToast(context, "Password changed successfully");
        } else {
          showErrorToast(context, response);
        }
      } catch (err) {
        log("message");
      }
    }
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
