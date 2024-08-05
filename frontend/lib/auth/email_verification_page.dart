import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'dart:developer';
class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  bool canResendEmail = true;
  String errorMessage = '';
  final userService = UserService();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    log(isEmailVerified.toString());
    if (!isEmailVerified) {
      sendVerificationEmail();
      timer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => checkEmailVerified(),
      );
    }
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if (isEmailVerified) timer?.cancel();
  }

  @override
  void dispose(){
    timer?.cancel();
    super.dispose();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final uid = user.uid;

      await userService.sendVerificationEmail(uid);

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(minutes: 1));
      setState(() => canResendEmail = true);
    } catch (e) {
      setState(() {
        errorMessage = 'Error sending email: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEmailVerified) {
      return HomePage();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              'Verify Email',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'We have sent you an email verification link.\nPlease check your inbox to activate your account.',
                style: TextStyle(fontSize: 20.0),
                textAlign: TextAlign.center,
              ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 24.0),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  minimumSize: Size.fromHeight(50),
                ),
                icon: const Icon(
                  Icons.email,
                  size: 32,
                ),
                label:const Text(
                  'Resend Email',
                  style: TextStyle(fontSize: 24.0),
                ),
                onPressed: canResendEmail ? sendVerificationEmail : null,
              ),
              const SizedBox(height: 8),
              TextButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 24.0),
                ),
                onPressed: () => FirebaseAuth.instance.signOut(),
              ),
            ],
          ),
        ),
      );
    }
  }
}
