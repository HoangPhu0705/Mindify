import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/auth/email_verification_page.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/my_textfield.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailcontroller = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailcontroller.dispose();
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
                  controller: _emailcontroller,
                  hintText: "Enter your email",
                  actionType: TextInputAction.next,
                  focusNode: emailFocusNode,
                  icon: Icons.email_outlined,
                  onFieldSubmitted: (value) {},
                  obsecure: false,
                  isPasswordTextField: false),
            ),
            AppSpacing.largeVertical,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: AppStyles.primaryButtonStyle,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmailVerificationScreen(),
                      ),
                    );
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
