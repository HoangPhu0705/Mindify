import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/services/models/comment.dart';
import 'package:frontend/services/models/reply.dart';
import 'package:frontend/utils/constants.dart';
import 'package:http/http.dart' as http;

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference comments =
      FirebaseFirestore.instance.collection('courses');

  Stream<QuerySnapshot> getCommentsStreamByCourse(String courseId) {
    return comments
        .doc(courseId)
        .collection('comments')
        .orderBy("createdAt", descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getReplieStreamByComment(
      String courseId, String commentId) {
    return comments
        .doc(courseId)
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .orderBy("createdAt", descending: false)
        .snapshots();
  }

  Future<List<Reply>> getReplies(String courseId, String commentId) async {
    QuerySnapshot replySnapshot = await comments
        .doc(courseId)
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .get();
    return replySnapshot.docs
        .map((doc) => Reply.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<Comment>> getComments(String courseId) async {
    final response = await http.get(
      Uri.parse("${AppConstants.COURSE_API}/$courseId/comments"),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Comment.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<String> createComment(String courseId, var data) async {
    try {
      final url = Uri.parse("${AppConstants.COURSE_API}/$courseId/comments");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 201) {
        log("Comment created successfully: ${response.body}");
        final commentId = response.body.split('"')[3];

        return commentId;
      } else {
        throw Exception("Error creating comment");
      }
    } catch (e) {
      log("Error: $e");
      throw Exception("Error creating comment");
    }
  }

  Future<void> createReply(String courseId, String commentId, var data) async {
    try {
      final url = Uri.parse(
          "${AppConstants.COURSE_API}/$courseId/comments/$commentId/replies");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 201) {
        log("Reply created successfully: ${response.body}");
      } else {
        throw Exception("Error creating reply");
      }
    } catch (e) {
      log("Error: $e");
      throw Exception("Error creating reply");
    }
  }
}
