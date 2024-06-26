import 'package:flutter/material.dart';
import 'package:frontend/pages/user_information/saved_classes.dart';
import 'package:frontend/utils/colors.dart';
import 'package:toastification/toastification.dart';

void showErrorToast(BuildContext context, String message) {
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

void showSuccessToast(BuildContext context, String message) {
  toastification.show(
    context: context,
    title: Text(
      message,
      style: const TextStyle(fontWeight: FontWeight.w500),
    ),
    showProgressBar: false,
    alignment: Alignment.bottomLeft,
    autoCloseDuration: const Duration(seconds: 2),
    type: ToastificationType.success,
  );
}

void showSavedSuccessToast(BuildContext context, String message) {
  toastification.show(
    context: context,
    closeButtonShowType: CloseButtonShowType.none,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return const SavedClasses();
                },
              ),
            );
          },
          child: const Text(
            "Saved classes",
            style: TextStyle(
              color: AppColors.deepBlue,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.deepBlue,
            ),
          ),
        )
      ],
    ),
    closeOnClick: false,
    showProgressBar: false,
    alignment: Alignment.bottomLeft,
    autoCloseDuration: const Duration(seconds: 4),
    type: ToastificationType.success,
  );
}
