// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last

import 'dart:async';
import 'dart:developer';

import 'package:comment_tree/comment_tree.dart' as ct;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/services/models/comment.dart';
import 'package:frontend/services/models/reply.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';

class Discussion extends StatefulWidget {
  final String courseId;
  final bool isEnrolled;

  const Discussion({super.key, required this.courseId, required this.isEnrolled});

  @override
  State<Discussion> createState() => _DiscussionState();
}

class _DiscussionState extends State<Discussion> {
  final TextEditingController _commentController = TextEditingController();
  final courseService = CourseService();
  final userService = UserService();
  final GlobalKey _commentFieldKey = GlobalKey();
  late StreamController<List<Comment>> _commentsStreamController;
  String userId = '';
  String? _replyToCommentId;

  @override
  void initState() {
    super.initState();
    userId = userService.getUserId();
    _commentsStreamController = StreamController<List<Comment>>.broadcast();
    _fetchComments();
  }

  @override
  void dispose() {
    _commentsStreamController.close();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    try {
      final comments = await courseService.getComments(widget.courseId);
      _commentsStreamController.add(comments);
    } catch (e) {
      log("Error fetching comments: $e");
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;

    final data = {
      'userId': userId,
      'content': _commentController.text,
    };

    try {
      if (_replyToCommentId == null) {
        final commentId = await courseService.createComment(widget.courseId, data);
        final newComment = Comment(
          id: commentId,
          userId: userId,
          content: data['content'] as String,
          createdAt: DateTime.now(),
          replies: [],
        );
        _updateComments((comments) => comments..add(newComment));
      } else {
        await _addReply(_replyToCommentId!, _commentController.text);
      }

      _replyToCommentId = null;
      _commentController.clear();

      FocusScope.of(context).unfocus();
    } catch (e) {
      log("Error adding comment or reply: $e");
    }
  }

  Future<void> _addReply(String commentId, String replyContent) async {
    final data = {
      'content': replyContent,
      'userId': userId,
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      final replyId = await courseService.createReply(widget.courseId, commentId, data);
      final newReply = Reply(
        id: replyId as String,
        userId: userId,
        content: replyContent,
        createdAt: DateTime.now(),
      );
      _updateComments((comments) {
        final comment = comments.firstWhere((comment) => comment.id == commentId);
        comment.replies.add(newReply);
        return comments;
      });
    } catch (e) {
      log("Error adding reply: $e");
    }
  }

  void _updateComments(List<Comment> Function(List<Comment>) update) {
    _commentsStreamController.addStream(
      _commentsStreamController.stream.first.then((comments) => Future.value(update(comments))).asStream(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        height: MediaQuery.of(context).size.height * 0.07,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: TextField(
          key: _commentFieldKey,
          controller: _commentController,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.ghostWhite,
            contentPadding: EdgeInsets.all(12),
            hintText: _replyToCommentId == null ? 'Start a discussion...' : 'Replying...',
            border: InputBorder.none,
            hintStyle: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 16),
            suffixIcon: IconButton(
              onPressed: _addComment,
              icon: Icon(Icons.send, color: AppColors.deepBlue),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(8, 12, 8, MediaQuery.of(context).size.height * 0.07),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: StreamBuilder<List<Comment>>(
                  stream: _commentsStreamController.stream,
                  builder: (context, snapshot) {
                    final comments = snapshot.data ?? [];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${comments.length} Discussions',
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        AppSpacing.mediumVertical,
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                _buildCommentTree(context, comments[index]),
                                Divider(color: AppColors.lighterGrey),
                              ],
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentTree(BuildContext context, Comment rootComment) {
    return ct.CommentTreeWidget<Comment, Reply>(
      rootComment,
      rootComment.replies,
      treeThemeData: ct.TreeThemeData(lineColor: AppColors.cream, lineWidth: 3),
      avatarRoot: (context, data) => PreferredSize(
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey,
          backgroundImage: AssetImage('assets/images/default_avatar.png'),
        ),
        preferredSize: Size.fromRadius(18),
      ),
      avatarChild: (context, data) => PreferredSize(
        child: CircleAvatar(
          radius: 12,
          backgroundColor: Colors.grey,
          backgroundImage: AssetImage('assets/images/default_avatar.png'),
        ),
        preferredSize: Size.fromRadius(12),
      ),

      // Root Comment
      contentRoot: (context, data) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.userId,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                  ),
                  AppSpacing.smallVertical,
                  Text(
                    data.content,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w300,
                          color: Colors.black,
                        ),
                  ),
                ],
              ),
            ),
            DefaultTextStyle(
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.grey[700], fontWeight: FontWeight.bold),
              child: Padding(
                padding: EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    AppSpacing.smallHorizontal,
                    Text('Like'),
                    AppSpacing.largeHorizontal,
                    TextButton(
                      onPressed: () => _prepareReply(rootComment.id),
                      child: Text(
                        'Reply',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      },
      
      contentChild: (context, data) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.userId,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                  ),
                  AppSpacing.smallVertical,
                  Text(
                    data.content,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w300,
                          color: Colors.black,
                        ),
                  ),
                ],
              ),
            ),
            DefaultTextStyle(
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.grey[700], fontWeight: FontWeight.bold),
              child: Padding(
                padding: EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    AppSpacing.smallHorizontal,
                    Text('Like'),
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }

  void _prepareReply(String commentId) {
    setState(() {
      _replyToCommentId = commentId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Scrollable.ensureVisible(_commentFieldKey.currentContext!, duration: Duration(milliseconds: 300));
        FocusScope.of(context).requestFocus(FocusNode());
        FocusScope.of(context).requestFocus(FocusNode());
      });
    });
  }
}
