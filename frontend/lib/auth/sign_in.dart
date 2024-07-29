import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/auth/forgot_password.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/user_information/view_profile_tabs/profile_page.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/my_textfield.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';

import 'package:sign_in_button/sign_in_button.dart';
import 'package:toastification/toastification.dart';

class SignIn extends StatefulWidget {
  final VoidCallback showSignUpPage;

  const SignIn({
    Key? key,
    required this.showSignUpPage,
  }) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  var _isObsecured;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  String userEmail = "";
  @override
  void initState() {
    super.initState();
    _isObsecured = true;
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   emailFocusNode.requestFocus();
    // });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordFocusNode.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> signInUser() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        showErrorToast("Incorrect email or passwords !");
      }
    }
  }

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

  void signInGoogle() async {
    try {
      GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      if (gUser == null) {
        showErrorToast("Google sign-in aborted.");
        return;
      }

      GoogleSignInAuthentication gAuth = await gUser.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      User? user = userCredential.user;

      if (user != null) {
        String uid = user.uid;
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (!userDoc.exists) {
          // Add to Firestore
          Map<String, dynamic> userData = {
            'id': uid,
            'displayName': user.displayName ?? 'Mindify Member',
            'email': user.email,
            'role': 'user',
            'requestSent': false,
            'followerNum': 0,
            'followingNum': 0,
            'followingUser': [],
            'followerUser': [],
            'savedClasses': [],
          };
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .set(userData);

          // Upload default avatar
          try {
            File defaultImageFile =
                await getImageFileFromAssets("images/default_avatar.png");
            Uint8List defaultImage = await defaultImageFile.readAsBytes();
            final storageRef = FirebaseStorage.instance.ref();
            final imageRef = storageRef.child('avatars/user_$uid');
            await imageRef.putData(defaultImage);
            var photoUrl = (await imageRef.getDownloadURL()).toString();
            await user.updatePhotoURL(photoUrl);
          } catch (e) {
            log("Error uploading avatar: $e");
          }
        }
      }
    } catch (e) {
      log("Error during Google sign-in: $e");
      showErrorToast("Error during Google sign-in");
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
      title: const Text(
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
    // Get the screen size
    final screenSize = MediaQuery.of(context).size;

    // Calculate dynamic padding and font size based on screen width
    final horizontalPadding = screenSize.width * 0.08;
    final verticalPadding = screenSize.height * 0.05;
    final titleFontSize = screenSize.width * 0.1;
    final labelFontSize = screenSize.width * 0.05;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Mindify.",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: titleFontSize,
                      ),
                ),
                AppSpacing.smallVertical,
                Text(
                  "Log into your account.",
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: labelFontSize,
                      ),
                ),
                AppSpacing.largeVertical,
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      MyTextField(
                          inputType: TextInputType.emailAddress,
                          controller: emailController,
                          hintText: "Email",
                          actionType: TextInputAction.next,
                          focusNode: emailFocusNode,
                          icon: Icons.email_outlined,
                          onFieldSubmitted: (value) {
                            FocusScope.of(context)
                                .requestFocus(passwordFocusNode);
                          },
                          obsecure: false,
                          isPasswordTextField: false),
                      AppSpacing.extraLargeVertical,
                      MyTextField(
                          inputType: TextInputType.visiblePassword,
                          controller: passwordController,
                          hintText: "Password",
                          actionType: TextInputAction.done,
                          icon: CupertinoIcons.padlock,
                          focusNode: passwordFocusNode,
                          obsecure: _isObsecured,
                          onFieldSubmitted: (value) {},
                          isPasswordTextField: true),
                      AppSpacing.mediumVertical,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgotPasswordScreen(),
                                ), // Trang đích
                              );
                            },
                            child: const Text(
                              "Forgot password?",
                              style: TextStyle(fontWeight: FontWeight.w300),
                            ),
                          )
                        ],
                      ),
                      AppSpacing.extraLargeVertical,
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: AppStyles.primaryButtonStyle,
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            if (_formKey.currentState!.validate()) {
                              signInUser();
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text("Login"),
                          ),
                        ),
                      ),
                      AppSpacing.mediumVertical,
                      Wrap(
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(fontWeight: FontWeight.w300),
                          ),
                          GestureDetector(
                            onTap: widget.showSignUpPage,
                            child: Transform.translate(
                              offset: const Offset(0, 2),
                              child: const Text(
                                "Create one",
                                style: TextStyle(
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, -2),
                                    ),
                                  ],
                                  color: Colors.transparent,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.mediumVertical,
                      Row(
                        children: [
                          const Flexible(
                            flex: 2,
                            child: Divider(),
                          ),
                          Flexible(
                            child: Center(
                                child: Text(
                              "OR",
                              style: Theme.of(context).textTheme.labelMedium,
                            )),
                          ),
                          const Flexible(
                            flex: 2,
                            child: Divider(),
                          ),
                        ],
                      ),
                      AppSpacing.smallVertical,
                      SizedBox(
                        width: double.infinity,
                        child: SignInButton(
                          Buttons.google,
                          text: "Login with Google",
                          onPressed: signInGoogle,
                          padding: const EdgeInsets.all(4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
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
