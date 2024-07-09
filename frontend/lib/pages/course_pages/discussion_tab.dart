import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comment_tree/comment_tree.dart' as ct;
import 'package:flutter/material.dart';
import 'package:frontend/services/functions/CommentService.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/services/models/comment.dart';
import 'package:frontend/services/models/reply.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/widgets/my_loading.dart';

class Discussion extends StatefulWidget {
  final String courseId;
  final bool isEnrolled;

  const Discussion(
      {super.key, required this.courseId, required this.isEnrolled});

  @override
  State<Discussion> createState() => _DiscussionState();
}

class _DiscussionState extends State<Discussion> {
  final TextEditingController _commentController = TextEditingController();
  final commentService = CommentService();
  final userService = UserService();
  final GlobalKey _commentFieldKey = GlobalKey();
  String userId = '';
  String? _replyToCommentId;
  List<Comment> comments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    userId = userService.getUserId();
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;

    final data = {
      'userId': userId,
      'content': _commentController.text,
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      if (_replyToCommentId == null) {
        await commentService.createComment(widget.courseId, data);
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
      await commentService.createReply(widget.courseId, commentId, data);
    } catch (e) {
      log("Error adding reply: $e");
    }
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
            hintText: _replyToCommentId == null
                ? 'Start a discussion...'
                : 'Replying...',
            border: InputBorder.none,
            hintStyle:
                Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 16),
            suffixIcon: IconButton(
              onPressed: _addComment,
              icon: Icon(Icons.send, color: AppColors.deepBlue),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: commentService.getCommentsStreamByCourse(widget.courseId),
          builder: (context, snapshot) {
            List<DocumentSnapshot> comments = snapshot.data!.docs;
            // log(comm.toList().toString());
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                      8, 12, 8, MediaQuery.of(context).size.height * 0.07),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${comments.length} Discussions',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
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
                                DocumentSnapshot doc = comments[index];
                                //           DocumentSnapshot document = folders[index];
                                // String folderId = document.id;
                                // Map<String, dynamic> data =
                                //     folders[index].data() as Map<String, dynamic>;
                                // String folderName = data['name'];
                                String commentId = doc.id;
                                Map<String, dynamic> data = comments[index]
                                    .data() as Map<String, dynamic>;
                                Comment comment = Comment(
                                    id: commentId,
                                    content: data['content'],
                                    userId: data['userId'],
                                    createdAt: data['createdAt'],
                                    replies: []);
                                return Column(
                                  children: [
                                    _buildCommentTree(context, comment),
                                    Divider(color: AppColors.lighterGrey),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }else{
              return MyLoading(width: 30, height: 30, color: AppColors.deepBlue);
            }
          }),
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

      // Child Comment
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
        Scrollable.ensureVisible(_commentFieldKey.currentContext!,
            duration: Duration(milliseconds: 300));
        FocusScope.of(context).requestFocus(FocusNode());
      });
    });
  }
}
