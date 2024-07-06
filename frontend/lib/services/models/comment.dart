class Comment {
  String id;
  String userId;
  String content;
  List<Comment> replies;

  Comment({
    required this.id,
    required this.userId,
    required this.content,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      replies: (json['replies'] as List<dynamic>?)
          ?.map((replyJson) => Comment.fromJson(replyJson as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'replies': replies.map((reply) => reply.toJson()).toList(),
    };
  }

  void addReply(Comment reply) {
    replies.add(reply);
  }
}