import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> reportCourse(String courseId, String courseTitle, String reason,
      String authorId) async {
    try {
      await _firestore.collection('reports').add({
        'courseId': courseId,
        'courseTitle': courseTitle,
        'authorId': authorId,
        'reason': reason,
        'from': FirebaseAuth.instance.currentUser!.email,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Error reporting course: $e');
    }
  }
}
