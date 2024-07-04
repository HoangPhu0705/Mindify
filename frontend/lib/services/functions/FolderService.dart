import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/services/models/folder.dart';
import 'package:frontend/utils/constants.dart';
import 'package:http/http.dart' as http;

class FolderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createFolder(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(AppConstants.FOLDER_API),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create folder');
    }
  }

  Future<List<Folder>> getFoldersOfUser(String userId) async {
    final response = await http.get(
      Uri.parse("${AppConstants.FOLDER_API}/userFolders?userId=$userId"),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Folder.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to get user folders');
    }
  }

  Future<void> addCourseToFolder(String folderId, String courseId) async {
    final response = await http.post(
      Uri.parse("${AppConstants.FOLDER_API}/addCourseToFolder"),
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode({'folderId': folderId, 'courseId': courseId}),
    );

    if (response.statusCode != 200) {
      log('Response body: ${response.body}');
      throw Exception('Failed to save course');
    }
  }
}
