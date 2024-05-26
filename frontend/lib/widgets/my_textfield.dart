// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';

class MyTextField extends StatefulWidget {
  final controller;
  final String hintText;
  bool obsecure;
  bool isPasswordTextField;
  MyTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obsecure,
    required this.isPasswordTextField,
  }) : super(key: key);

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) {
        if (widget.isPasswordTextField) {
        } else {
          EmailValidator.validate(value);
        }
      },
      controller: widget.controller,
      cursorColor: AppColors.blue,
      obscureText: widget.obsecure,
      decoration: InputDecoration(
        prefixIcon: widget.isPasswordTextField
            ? const Icon(CupertinoIcons.padlock)
            : const Icon(Icons.email_outlined),
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

class EmailValidator {
  static String? validate(String? value) {
    if (value!.isEmpty) {
      return 'Email không được bỏ trống';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }
}
