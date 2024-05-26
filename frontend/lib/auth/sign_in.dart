import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/widgets/my_textfield.dart';
import 'package:pretty_animated_buttons/pretty_animated_buttons.dart';
import 'package:pretty_animated_buttons/widgets/pretty_border_button.dart';
import 'package:pretty_animated_buttons/widgets/pretty_wave_button.dart';
import 'package:sign_in_button/sign_in_button.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  var _isObsecured;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _isObsecured = true;
  }

  void signInUser() {
    log("signin user");
  }

  void singInGoogle() {}

  void signInFacebook() {}

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
                "Log into your account.",
                style: Theme.of(context).textTheme.labelLarge,
              ),
              AppSpacing.largeVertical,
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    MyTextField(
                        controller: emailController,
                        hintText: "Email",
                        obsecure: false,
                        isPasswordTextField: false),
                    AppSpacing.extraLargeVertical,
                    MyTextField(
                        controller: passwordController,
                        hintText: "Password",
                        obsecure: _isObsecured,
                        isPasswordTextField: true),
                    AppSpacing.mediumVertical,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              signInUser();
                            }
                          },
                          child: Text(
                            "Forgot password?",
                            style: TextStyle(fontWeight: FontWeight.w300),
                          ),
                        )
                      ],
                    ),
                    AppSpacing.extraLargeVertical,
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(0),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(AppColors.cream),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.black),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        onPressed: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text("Login"),
                        ),
                      ),
                    ),
                    AppSpacing.mediumVertical,
                    Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: Divider(),
                        ),
                        Flexible(
                          child: Center(
                              child: Text(
                            "OR",
                            style: Theme.of(context).textTheme.labelMedium,
                          )),
                        ),
                        Flexible(
                          flex: 2,
                          child: Divider(),
                        ),
                      ],
                    ),
                    AppSpacing.smallVertical,
                    SizedBox(
                      width: double.infinity,
                      child: SignInButton(
                        Buttons.facebook,
                        text: "Login with Facebook",
                        onPressed: () {},
                        padding: EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    AppSpacing.smallVertical,
                    SizedBox(
                      width: double.infinity,
                      child: SignInButton(
                        Buttons.google,
                        text: "Login with Google",
                        onPressed: () {},
                        padding: EdgeInsets.all(4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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
