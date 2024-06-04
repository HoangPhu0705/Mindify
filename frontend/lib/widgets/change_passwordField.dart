// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';

class ChangePasswordField extends StatefulWidget {
  bool obsecure;
  final String title;
  ChangePasswordField({
    Key? key,
    required this.obsecure,
    required this.title,
  }) : super(key: key);

  @override
  State<ChangePasswordField> createState() => _ChangePasswordFieldState();
}

class _ChangePasswordFieldState extends State<ChangePasswordField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: widget.obsecure,
      decoration: InputDecoration(
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.lightGrey),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.blue),
        ),
        hintText: widget.title,
        hintStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.lightGrey,
        ),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              widget.obsecure = !widget.obsecure;
            });
          },
          icon: Icon(widget.obsecure
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined),
        ),
      ),
    );
  }
}
