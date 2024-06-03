import 'package:flutter/material.dart';
import 'package:frontend/auth/auth_page.dart';
import 'package:frontend/auth/reset_password.dart';
import 'package:frontend/auth/sign_in.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';

class EmailVerificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Mindify.", style: Theme.of(context).textTheme.displayLarge),
              AppSpacing.largeVertical,
              Text(
                'We have emailed your password reset link.\nPlease check your inboxes',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              AppSpacing.largeVertical,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppStyles.primaryButtonStyle,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AuthPage(),
                      ), // Trang đích
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text("Confirm"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
