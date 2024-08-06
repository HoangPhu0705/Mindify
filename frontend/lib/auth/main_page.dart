import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/auth/auth_page.dart';
import 'package:frontend/auth/email_verification_page.dart';
import 'package:frontend/services/functions/AuthService.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user is logged in
          if (snapshot.hasData) {
            return const VerifyEmailPage();
          }
          // user is NOT logged in
          else {
            return const AuthPage();
          }
        },
      ),
    );
  }
}
