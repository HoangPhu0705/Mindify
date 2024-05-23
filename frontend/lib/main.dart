import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/auth/sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MindifyApp());
}

class MindifyApp extends StatefulWidget {
  const MindifyApp({super.key});

  @override
  State<MindifyApp> createState() => MindifyAppState();
}

class MindifyAppState extends State<MindifyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignIn(),
    );
  }
}
