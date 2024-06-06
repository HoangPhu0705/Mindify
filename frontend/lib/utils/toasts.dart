import 'package:flutter/material.dart';
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
      style: TextStyle(fontWeight: FontWeight.w500),
    ),
    showProgressBar: false,
    alignment: Alignment.bottomLeft,
    autoCloseDuration: const Duration(seconds: 2),
    type: ToastificationType.success,
  );
}
