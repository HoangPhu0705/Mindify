import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
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
                    AppSpacing.mediumVertical,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {},
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
                        style: AppStyles.primaryButtonStyle,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            signInUser();
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text("Login"),
                        ),
                      ),
                    ),
                    AppSpacing.mediumVertical,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(fontWeight: FontWeight.w300),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Transform.translate(
                            offset: const Offset(0, 2),
                            child: const Text(
                              "Create one",
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
>>>>>>> 7c8f5b0a08d7419405a49cbf516d4bc24a0651a1
    );
  }
}
