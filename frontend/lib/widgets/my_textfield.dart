// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';

class MyTextField extends StatefulWidget {
  final controller;
  final String hintText;
  final IconData icon;
  bool obsecure;
  bool isPasswordTextField;
  MyTextField({
    Key? key,
    required this.controller,
    required this.icon,
    required this.hintText,
    required this.obsecure,
    required this.isPasswordTextField,
  }) : super(key: key);

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

String? validateEmail(String? value) {
  if (value!.isEmpty) {
    return 'Please fill in your email';
  }
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'Invalid email, please try again';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value!.isEmpty) {
    return "Please fill in your password";
  }

  if (value.length < 6) {
    return "Password must be at least 6 characters";
  }

  return null;
}

String? validateUsername(String? value) {
  if (value!.isEmpty) {
    return "Please choose a username";
  }

  return null;
}

class _MyTextFieldState extends State<MyTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) {
        if (widget.isPasswordTextField) {
          return validatePassword(value);
        } else {
          if (widget.hintText == "Username") {
            return validateUsername(value);
          }
          return validateEmail(value);
        }
      },
      controller: widget.controller,
      cursorColor: AppColors.blue,
      obscureText: widget.obsecure,
      decoration: InputDecoration(
        prefixIcon: Icon(widget.icon),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.grey),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.blue),
        ),
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          color: AppColors.grey,
        ),
        suffixIcon: widget.isPasswordTextField
            ? IconButton(
                onPressed: () {
                  setState(() {
                    widget.obsecure = !widget.obsecure;
                  });
                },
                icon: Icon(widget.obsecure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
              )
            : null,
      ),
    );
  }
}
