import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/services/functions/AuthService.dart';
import 'package:frontend/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ReminderService {
  String idToken = AuthService.idToken!;

  Future<void> addReminder(String userId, String day, String time) async {
    final response = await http.post(
      Uri.parse('${AppConstants.USER_API}/$userId/Reminder'),
      headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      body: jsonEncode(<String, String>{
        'day': day,
        'time': time,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add reminder: ${response.reasonPhrase}');
    }
  }

  Stream<QuerySnapshot> getUserRemindersStream(User? user) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('reminders')
        .orderBy(
          'created_at',
          descending: true,
        )
        .snapshots();
  }

  Future<void> deleteReminder(String userId, String reminderId) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.USER_API}/$userId/reminder/$reminderId'),
      headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete reminder: ${response.reasonPhrase}');
    }
  }
}
