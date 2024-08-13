import 'package:flutter/material.dart';
import 'package:frontend/services/models/folder.dart';
import 'package:frontend/services/functions/FolderService.dart';
import 'package:provider/provider.dart';

class FolderProvider extends ChangeNotifier {
  final FolderService _folderService = FolderService();
  List<Folder> _folders = [];
  bool _isLoading = false;

  List<Folder> get folders => _folders;
  bool get isLoading => _isLoading;

  Future<void> fetchFolders(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _folders = await _folderService.getFoldersOfUser(userId);
    } catch (e) {
      print('Error fetching folders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  } 

  Future<void> createFolder(String userId, String folderName) async {
    try {
      await _folderService.createFolder({'name': folderName, 'userId': userId});
      fetchFolders(userId);
    } catch (e) {
      print('Error creating folder: $e');
    }
  }

  Future<void> addCourseToFolder(String folderId, String courseId) async {
    try {
      await _folderService.addCourseToFolder(folderId, courseId);
      _folders
          .firstWhere((folder) => folder.id == folderId)
          .courses
          .add(courseId);
      notifyListeners();
    } catch (e) {
      print('Error adding course to folder: $e');
    }
  }
}
