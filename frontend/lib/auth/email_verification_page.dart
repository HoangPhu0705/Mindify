// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:developer';
import 'package:frontend/pages/home_page.dart';
// import 'package:cookie_app/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/styles.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerify = false;
  bool canResendEmail = false;
  // UserService userService = UserService(FirebaseAuth.instance.currentUser!);
  Timer? timer;

  @override
  void initState() {
    super.initState();
    isEmailVerify = FirebaseAuth.instance.currentUser!.emailVerified;
    if (!isEmailVerify) {
      sendVerifycationEmail();
      timer = Timer.periodic(
        Duration(seconds: 5),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerify = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if (isEmailVerify) timer?.cancel();
  }

  Future sendVerifycationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      log("error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEmailVerify) {
      log("Email is verified");
      return HomePage();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              'Verify Email',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.mark_email_read_outlined,
                size: 100,
                color: AppColors.deepSpace,
              ),
              Text(
                'We have emailed your activation link.\nPlease check your inboxes to activate your account.',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 24.0,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: AppStyles.primaryButtonStyle.copyWith(
                    backgroundColor: canResendEmail
                        ? WidgetStateProperty.all(AppColors.lighterGrey)
                        : WidgetStateProperty.all(
                            AppColors.cream,
                          ),
                  ),
                  icon: Icon(
                    Icons.send,
                    size: 32,
                  ),
                  label: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Resend email',
                      style: TextStyle(fontSize: 24.0),
                    ),
                  ),
                  onPressed: canResendEmail ? sendVerifycationEmail : null,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              TextButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(50),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: AppColors.deepBlue,
                  ),
                ),
                onPressed: () => FirebaseAuth.instance.signOut(),
              )
            ],
          ),
        ),
      );
    }
  }
}
