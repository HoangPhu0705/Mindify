import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/utils/toasts.dart';
import 'package:frontend/widgets/my_textfield.dart';
import 'package:provider/provider.dart';
import 'package:frontend/services/providers/UserProvider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        emailFocusNode.requestFocus();
      },
    );
  }

  Future<void> _resetPassword() async {
    final userService = UserService();
    try {
      // hide keyboard
      FocusScope.of(context).unfocus();
      await userService.resetPassword(_emailController.text);
      if (mounted) {
        showSuccessToast(
            context, "Password reset email sent, please check your inbox.");
        await Future.delayed(const Duration(seconds: 2));

        // Go back to login
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Mindify.", style: Theme.of(context).textTheme.displayLarge),
            AppSpacing.mediumVertical,
            Text(
              'Forgot Password.',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            AppSpacing.largeVertical,
            Form(
              key: _formKey,
              child: MyTextField(
                inputType: TextInputType.emailAddress,
                controller: _emailController,
                hintText: "Enter your email",
                actionType: TextInputAction.next,
                focusNode: emailFocusNode,
                icon: Icons.email_outlined,
                onFieldSubmitted: (value) {},
                obsecure: false,
                isPasswordTextField: false,
              ),
            ),
            AppSpacing.largeVertical,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: AppStyles.primaryButtonStyle,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _resetPassword();
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("Submit"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
