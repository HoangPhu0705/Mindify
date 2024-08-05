import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await Firebase.initializeApp();

    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission');
      await _configureFCM();
    } else {
      log('User declined or has not accepted permission');
    }
  }

  Future<void> _configureFCM() async {
    // Cấu hình local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Lưu token vào Firestore
    await saveTokenToDatabase();

    // Lắng nghe các thông báo khi ứng dụng đang ở foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Received message while app is in the foreground!');
      log('Message data: ${message.data}');
      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
        _showLocalNotification(message.notification!);
      }
    });

    // Lắng nghe khi người dùng nhấn vào thông báo
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('User tapped on a notification!');
      log('Message data: ${message.data}');
    });

    // Xử lý thông báo khi ứng dụng ở chế độ nền hoặc bị đóng
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _showLocalNotification(RemoteNotification notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'mindify_id', 
      'mindify_app', 
      channelDescription: 'You have a notification', 
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformChannelSpecifics,
    );
  }

  Future<void> saveTokenToDatabase() async {
    String? token = await _fcm.getToken();
    log('FCM Token: $token');

    if (token != null) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        DocumentReference userRef =
            FirebaseFirestore.instance.collection('users').doc(userId);

        try {
          await FirebaseFirestore.instance.runTransaction((transaction) async {
            DocumentSnapshot userDoc = await transaction.get(userRef);

            if (userDoc.exists) {
              Map<String, dynamic>? userData =
                  userDoc.data() as Map<String, dynamic>?;
              List<String> tokens =
                  List<String>.from(userData?['deviceTokens'] ?? []);
              if (!tokens.contains(token)) {
                tokens.add(token);
                transaction.update(userRef, {'deviceTokens': tokens});
              }
            } else {
              transaction.set(userRef, {
                'deviceTokens': [token],
              });
            }
          });
        } catch (e) {
          log('Failed to save token to database: $e');
        }
      }
    }
  }

  Future<void> deleteTokenFromDatabase() async {
    String? token = await _fcm.getToken();
    log('FCM Token: $token');

    if (token != null) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        DocumentReference userRef =
            FirebaseFirestore.instance.collection('users').doc(userId);

        try {
          await FirebaseFirestore.instance.runTransaction((transaction) async {
            DocumentSnapshot userDoc = await transaction.get(userRef);

            if (userDoc.exists) {
              Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
              List<String> tokens = List<String>.from(userData?['deviceTokens'] ?? []);
              if (tokens.contains(token)) {
                tokens.remove(token);
                transaction.update(userRef, {'deviceTokens': tokens});
              }
            }
          });
        } catch (e) {
          log('Failed to delete token from database: $e');
        }
      }
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    log("Handling a background message: ${message.messageId}");
  }
}
