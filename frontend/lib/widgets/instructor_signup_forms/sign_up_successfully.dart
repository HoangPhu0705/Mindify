import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:lottie/lottie.dart';

class SendSuccessfully extends StatefulWidget {
  const SendSuccessfully({super.key});

  @override
  State<SendSuccessfully> createState() => _SendSuccessfullyState();
}

class _SendSuccessfullyState extends State<SendSuccessfully> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.deepSpace,
          ),
          child: Column(
            children: [
              const SizedBox(
                height: 100,
              ),
              Lottie.asset(
                'assets/animation/request_succeed.json',
                width: 200,
                height: 200,
                repeat: false,
              ),
              const Text(
                "Your application has been sent successfully!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.mediumVertical,
              Text(
                "We will review your application and get back to you as soon as possible.",
                style: TextStyle(
                  color: Colors.grey[200],
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.mediumVertical,
              Text(
                "Thank you for your interest in teaching with us!",
                style: TextStyle(
                  color: Colors.grey[200],
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.mediumVertical,
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: AppStyles.primaryButtonStyle,
                child: Text("Back to Home"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
