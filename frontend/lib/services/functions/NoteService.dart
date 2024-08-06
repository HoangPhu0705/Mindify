import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/services/functions/AuthService.dart';
import 'package:frontend/utils/constants.dart';
import 'package:http/http.dart' as http;

class NoteService {
  String idToken = AuthService.idToken!;

  Stream<QuerySnapshot> getNoteStream(String enrollmentId) {
    return FirebaseFirestore.instance
        .collection('enrollments')
        .doc(enrollmentId)
        .collection('notes')
        .snapshots();
  }

  Future<String> addNote(String enrollmentId, Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConstants.ENROLLMENT_API}/$enrollmentId/notes');
    final response = await http.post(
      url,
      headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      body: jsonEncode({'enrollmentId': enrollmentId, 'data': data}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['noteId'];
    } else {
      throw Exception('Failed to add note: ${response.body}');
    }
  }

  Future<void> deleteNote(String enrollmentId, String noteId) async {
    final url =
        Uri.parse('${AppConstants.ENROLLMENT_API}/$enrollmentId/$noteId');
    final response = await http.delete(url, headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete note: ${response.body}');
    }
  }

  Future<void> updateNote(
      String enrollmentId, String noteId, Map<String, dynamic> data) async {
    final url =
        Uri.parse('${AppConstants.ENROLLMENT_API}/$enrollmentId/$noteId');
    final response = await http.put(
      url,
      headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update note: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getAllNotesOfEnrollment(
      String enrollmentId) async {
    final url = Uri.parse('${AppConstants.ENROLLMENT_API}/$enrollmentId/notes');
    final response = await http.get(url, headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body) as List;
      return responseData.map((note) => note as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to retrieve notes: ${response.body}');
    }
  }
}
