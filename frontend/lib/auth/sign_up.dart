// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/my_textfield.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toastification/toastification.dart';

class SignUp extends StatefulWidget {
  final VoidCallback showLoginPage;
  const SignUp({
    Key? key,
    required this.showLoginPage,
  }) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  //Controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  var _isObsecured;
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _isObsecured = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      emailFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  //Functions

  //Get default avatar
  Future<File> getImageFileFromAssets(String path) async {
    try {
      final byteData = await rootBundle.load('assets/$path');
      final file = File('${(await getTemporaryDirectory()).path}/$path');
      await file.create(recursive: true); // Ensure the directory exists
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      return file;
    } catch (e) {
      log("Error loading asset: $e");
      rethrow;
    }
  }

  //Sign up function
  Future<void> signUpUser() async {
    String email = emailController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    String password = passwordController.text.trim();

    if (confirmPassword != password) {
      showErrorToast("Confirm password does not match");
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid = userCredential.user!.uid;

      // Add to Firestore
      Map<String, dynamic> userData = {
        'id': uid,
        'displayName': 'Mindify Member',
        'email': email,
        'role': 'user',
        'requestSent': false,
        'savedClasses': [],
      };
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userData);

      try {
        File defaultImageFile =
            await getImageFileFromAssets("images/default_avatar.png");
        Uint8List defaultImage = await defaultImageFile.readAsBytes();
        final storageRef = FirebaseStorage.instance.ref();
        final imageRef = storageRef.child('avatars/user_$uid');
        await imageRef.putData(defaultImage);
        var photoUrl = (await imageRef.getDownloadURL()).toString();
        await userCredential.user!.updatePhotoURL(photoUrl);
      } catch (e) {
        log("Error uploading avatar: $e");
      }
    } on FirebaseAuthException catch (e) {
      log("Error: $e");
      if (e.code == 'invalid-credential') {
        showErrorToast("Incorrect email or password!");
      } else {
        showErrorToast("Error: ${e.message}");
      }
    }
  }

  void showErrorToast(String message) {
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

  void showSuccessToast() {
    toastification.show(
      context: context,
      title: Text(
        'Account created',
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      showProgressBar: false,
      alignment: Alignment.bottomLeft,
      autoCloseDuration: const Duration(seconds: 2),
      type: ToastificationType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(32, 56, 32, 0),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Mindify.",
                    style: Theme.of(context).textTheme.displayLarge),
                AppSpacing.smallVertical,
                Text(
                  "Create an Account.",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                AppSpacing.largeVertical,
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      MyTextField(
                          actionType: TextInputAction.next,
                          controller: emailController,
                          inputType: TextInputType.emailAddress,
                          hintText: "Email",
                          icon: Icons.email_outlined,
                          obsecure: false,
                          focusNode: emailFocusNode,
                          onFieldSubmitted: (value) {
                            FocusScope.of(context)
                                .requestFocus(passwordFocusNode);
                          },
                          isPasswordTextField: false),
                      AppSpacing.extraLargeVertical,
                      MyTextField(
                          controller: passwordController,
                          actionType: TextInputAction.next,
                          inputType: TextInputType.visiblePassword,
                          hintText: "Password",
                          icon: CupertinoIcons.padlock,
                          obsecure: _isObsecured,
                          focusNode: passwordFocusNode,
                          onFieldSubmitted: (value) {
                            FocusScope.of(context)
                                .requestFocus(confirmPasswordFocusNode);
                          },
                          isPasswordTextField: true),
                      AppSpacing.extraLargeVertical,
                      MyTextField(
                          actionType: TextInputAction.done,
                          controller: confirmPasswordController,
                          inputType: TextInputType.visiblePassword,
                          hintText: "Confirm Password",
                          icon: CupertinoIcons.padlock,
                          obsecure: _isObsecured,
                          focusNode: confirmPasswordFocusNode,
                          onFieldSubmitted: (value) {},
                          isPasswordTextField: true),
                      AppSpacing.extraLargeVertical,
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: AppStyles.primaryButtonStyle,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              signUpUser();
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text("Sign Up"),
                          ),
                        ),
                      ),
                      AppSpacing.mediumVertical,
                      Wrap(
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(fontWeight: FontWeight.w300),
                          ),
                          GestureDetector(
                            onTap: widget.showLoginPage,
                            child: Transform.translate(
                              offset: const Offset(0, 2),
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  shadows: [Shadow(offset: Offset(0, -2))],
                                  color: Colors.transparent,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
