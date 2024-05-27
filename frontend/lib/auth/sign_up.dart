import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/my_textfield.dart';
import 'package:toastification/toastification.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  var _isObsecured;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _isObsecured = true;
  }

  void signUpUser() {
    String email = emailController.text.trim();
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    try {
      showSuccessToast();
    } catch (e) {}
  }

  void showSuccessToast() {
    toastification.show(
      context: context,
      title: Text(
        'Account created',
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      showProgressBar: false,
      alignment: Alignment.bottomLeft,
      autoCloseDuration: const Duration(seconds: 2),
      type: ToastificationType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(32, 56, 32, 0),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Mindify.", style: Theme.of(context).textTheme.displayLarge),
              AppSpacing.smallVertical,
              Text(
                "Create an Account.",
                style: Theme.of(context).textTheme.labelLarge,
              ),
              AppSpacing.largeVertical,
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    MyTextField(
                        controller: usernameController,
                        hintText: "Username",
                        icon: Icons.account_box_outlined,
                        obsecure: false,
                        isPasswordTextField: false),
                    AppSpacing.extraLargeVertical,
                    MyTextField(
                        controller: emailController,
                        hintText: "Email",
                        icon: Icons.email_outlined,
                        obsecure: false,
                        isPasswordTextField: false),
                    AppSpacing.extraLargeVertical,
                    MyTextField(
                        controller: passwordController,
                        hintText: "Password",
                        icon: CupertinoIcons.padlock,
                        obsecure: _isObsecured,
                        isPasswordTextField: true),
                    AppSpacing.extraLargeVertical,
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: AppStyles.primaryButtonStyle,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            signUpUser();
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text("Sign Up"),
                        ),
                      ),
                    ),
                    AppSpacing.mediumVertical,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(fontWeight: FontWeight.w300),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Transform.translate(
                            offset: const Offset(0, 2),
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                shadows: [Shadow(offset: Offset(0, -2))],
                                color: Colors.transparent,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
