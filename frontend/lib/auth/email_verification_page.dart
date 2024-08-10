import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/services/functions/AuthService.dart';
import 'package:frontend/services/functions/NotificationService.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'dart:developer';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/my_loading.dart';

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
  late Future _future;

  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();
      timer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => checkEmailVerified(),
      );
    }
    _future = initToken();
  }

  Future<void> _initializeNotificationService() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _notificationService.initialize();
    } else {
      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        if (user != null) {
          await _notificationService.initialize();
        }
      });
    }
  }

  Future<void> _initializeToken() async {
    User? user = FirebaseAuth.instance.currentUser;

    await AuthService.initializeIdToken(user!);
  }

  Future<void> initToken() async {
    await _initializeNotificationService();
    await _initializeToken();
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if (isEmailVerified) timer?.cancel();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future sendVerificationEmail() async {
    try {
      log("Preparing to send email");
      final user = FirebaseAuth.instance.currentUser!;
      final uid = user.uid;

      await userService.sendVerificationEmail(uid);
      log("Email sent");

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
      return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: MyLoading(
                width: 30,
                height: 30,
                color: AppColors.deepBlue,
              ),
            );
          }

          return const HomePage();
        },
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Center(
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
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                size: 100,
                color: AppColors.deepSpace,
              ),
              const Text(
                'We have emailed your verification link.\nPlease check your inboxes to activate your account.',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
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
                  icon: const Icon(
                    Icons.send,
                    size: 32,
                  ),
                  label: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Resend email',
                      style: TextStyle(fontSize: 24.0),
                    ),
                  ),
                  onPressed: canResendEmail ? sendVerificationEmail : null,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: AppColors.deepBlue,
                  ),
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
