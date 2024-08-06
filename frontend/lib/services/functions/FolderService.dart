import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/services/functions/AuthService.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/services/models/folder.dart';
import 'package:frontend/utils/constants.dart';
import 'package:http/http.dart' as http;

class FolderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String idToken = AuthService.idToken!;

  final CollectionReference folders =
      FirebaseFirestore.instance.collection('folders');

  Stream<QuerySnapshot> getFolderStreamByUser(String userId) {
    final foldersStream =
        folders.where('userId', isEqualTo: userId).snapshots();
    return foldersStream;
  }

  Future<void> updateFolder(
      String folderId, Map<String, dynamic> updatedData) async {
    try {
      await folders.doc(folderId).update(updatedData);
      log('Folder updated successfully');
    } catch (e) {
      log('Error updating folder: $e');
    }
  }

  Future<void> createFolder(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(AppConstants.FOLDER_API),
      headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create folder');
    }
  }

  //get folder from id
  Future<Folder> getFolder(String folderId) async {
    final response = await http.get(
      Uri.parse("${AppConstants.FOLDER_API}/$folderId"),
      headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
    );

    if (response.statusCode == 200) {
      return Folder.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get folder');
    }
  }

  //delete folder
  Future<void> deleteFolder(String folderId) async {
    final response = await http.delete(
      Uri.parse("${AppConstants.FOLDER_API}/$folderId"),
      headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete folder');
    }
  }

  Future<List<Folder>> getFoldersOfUser(String userId) async {
    final response = await http.get(
      Uri.parse("${AppConstants.FOLDER_API}/userFolders?userId=$userId"),
      headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => Folder.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to get user folders');
    }
  }

  Future<void> addCourseToFolder(String folderId, String courseId) async {
    final response = await http.post(
      Uri.parse("${AppConstants.FOLDER_API}/addCourseToFolder"),
      headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      body: json.encode({'folderId': folderId, 'courseId': courseId}),
    );

    if (response.statusCode != 200) {
      log('Response body: ${response.body}');
      throw Exception('Failed to save course');
    }
  }

  Future<List<dynamic>> getCoursesIdFromFolder(String folderId) async {
    final response = await http.get(
      Uri.parse("${AppConstants.FOLDER_API}/$folderId/courses"),
      headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.toList();
    } else {
      throw Exception('Failed to get courses');
    }
  }

  Future<void> removeCourseFromFolder(String folderId, String courseId) {
    return http
        .delete(
      Uri.parse("${AppConstants.FOLDER_API}/$folderId/removeCourse/$courseId"),
      headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
    )
        .then((response) {
      if (response.statusCode != 200) {
        throw Exception('Failed to remove course');
      }
    });
  }
}
