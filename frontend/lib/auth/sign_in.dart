// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:frontend/auth/forgot_password.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/user_information/view_profile_tabs/profile_page.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/my_textfield.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pretty_animated_buttons/pretty_animated_buttons.dart';
import 'package:pretty_animated_buttons/widgets/pretty_border_button.dart';
import 'package:pretty_animated_buttons/widgets/pretty_wave_button.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:toastification/toastification.dart';

class SignIn extends StatefulWidget {
  final VoidCallback showSignUpPage;

  const SignIn({
    Key? key,
    required this.showSignUpPage,
  }) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  var _isObsecured;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  String userEmail = "";
  @override
  void initState() {
    super.initState();
    _isObsecured = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      emailFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordFocusNode.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> signInUser() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        showErrorToast("Incorrect email or passwords !");
      }
    }
  }

  void signInGoogle() async {
    GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    GoogleSignInAuthentication? gAuth = await gUser?.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: gAuth?.accessToken,
      idToken: gAuth?.idToken,
    );

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
  }

  void showErrorToast(String message) {
    toastification.show(
      context: context,
      title: Text(
        message,
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      showProgressBar: false,
      alignment: Alignment.bottomLeft,
      autoCloseDuration: const Duration(seconds: 3),
      type: ToastificationType.error,
    );
  }

  void showSuccessToast() {
    toastification.show(
      context: context,
      title: const Text(
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
                "Log into your account.",
                style: Theme.of(context).textTheme.labelLarge,
              ),
              AppSpacing.largeVertical,
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    MyTextField(
                        inputType: TextInputType.emailAddress,
                        controller: emailController,
                        hintText: "Email",
                        actionType: TextInputAction.next,
                        focusNode: emailFocusNode,
                        icon: Icons.email_outlined,
                        onFieldSubmitted: (value) {
                          FocusScope.of(context)
                              .requestFocus(passwordFocusNode);
                        },
                        obsecure: false,
                        isPasswordTextField: false),
                    AppSpacing.extraLargeVertical,
                    MyTextField(
                        inputType: TextInputType.visiblePassword,
                        controller: passwordController,
                        hintText: "Password",
                        actionType: TextInputAction.done,
                        icon: CupertinoIcons.padlock,
                        focusNode: passwordFocusNode,
                        obsecure: _isObsecured,
                        onFieldSubmitted: (value) {},
                        isPasswordTextField: true),
                    AppSpacing.mediumVertical,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ForgotPasswordScreen()), // Trang đích
                            );
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
                        style: AppStyles.primaryButtonStyle,
                        onPressed: () {
                          FocusScope.of(context).unfocus();
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
                          onTap: widget.showSignUpPage,
                          child: Transform.translate(
                            offset: const Offset(0, 2),
                            child: const Text(
                              "Create one",
                              style: TextStyle(
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, -2),
                                  ),
                                ],
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
                        Buttons.google,
                        text: "Login with Google",
                        onPressed: signInGoogle,
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
