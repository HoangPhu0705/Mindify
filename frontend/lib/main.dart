import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:frontend/auth/email_verification_page.dart';
import 'package:frontend/auth/main_page.dart';
import 'package:frontend/firebase_options.dart';
import 'package:flutter/services.dart';
import 'package:frontend/pages/splash_screen.dart';
import 'package:frontend/services/functions/AuthService.dart';
import 'package:frontend/services/functions/FolderService.dart';
import 'package:frontend/services/providers/EnrollmentProvider.dart';
import 'package:frontend/services/providers/FolderProvider.dart';
import 'package:frontend/services/providers/UserProvider.dart';
import 'package:frontend/services/providers/CourseProvider.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show
        GlobalCupertinoLocalizations,
        GlobalMaterialLocalizations,
        GlobalWidgetsLocalizations;
import 'package:flutter_quill/flutter_quill.dart' show Document;
import 'package:flutter_quill/translations.dart' show FlutterQuillLocalizations;
import 'package:frontend/services/functions/NotificationService.dart';

// import 'package:stripe_payment/stripe_payment.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // await Firebase.initializeApp();
  log("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MindifyApp());
}

class MindifyApp extends StatefulWidget {
  const MindifyApp({super.key});

  @override
  State<MindifyApp> createState() => _MindifyAppState();
}

class _MindifyAppState extends State<MindifyApp> {
  final NotificationService _notificationService = NotificationService();
  @override
  void initState() {
    _initializeNotificationService();
    _initializeToken();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColors.ghostWhite,
      statusBarIconBrightness: Brightness.dark,
    ));
    super.initState();
  }

  Future<void> _initializeNotificationService() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _notificationService.initialize();
    } else {
      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        if (user != null) {
          await _notificationService.initialize();
        }
      });
    }
  }

  Future<void> _initializeToken() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await AuthService.initializeIdToken(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => CourseProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => EnrollmentProvider(),
        ),
        ChangeNotifierProvider(create: (_) => FolderProvider()),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          // Uncomment this line to use provide flutter quill localizations
          // in your widgets app, otherwise the quill widgets will provide it
          // internally:
          // FlutterQuillLocalizations.delegate,
        ],
        supportedLocales: FlutterQuillLocalizations.supportedLocales,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.ghostWhite,
          fontFamily: 'Poppins',
          textTheme: const TextTheme(
            displayLarge: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: AppColors.blue),
            displaySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            headlineMedium: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.blue),
            titleLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            titleMedium: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
            labelLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            labelMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
