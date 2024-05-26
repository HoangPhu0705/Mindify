import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:frontend/auth/sign_in.dart';
import 'package:frontend/auth/sign_up.dart';
import 'package:frontend/firebase_options.dart';
import 'package:flutter/services.dart';
import 'package:frontend/utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MindifyApp());
}

class MindifyApp extends StatefulWidget {
  const MindifyApp({super.key});

  @override
  State<MindifyApp> createState() => _MindifyAppState();
}

class _MindifyAppState extends State<MindifyApp> {
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 40, fontWeight: FontWeight.w700, color: AppColors.blue),
          labelLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          labelMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      home: SignUp(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
