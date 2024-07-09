import 'package:frontend/services/models/reply.dart';

class Comment {
  String id;
  String userId;
  String content;
  String createdAt;
  List<Reply> replies;

  Comment({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      createdAt: (json['createdAt'] as String),
      replies: (json['replies'] as List<dynamic>?)
              ?.map((replyJson) => Reply.fromJson(replyJson as Map<String, dynamic>)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'createdAt': createdAt,
      'replies': replies.map((reply) => reply.toJson()).toList(),
    };
  }
}
