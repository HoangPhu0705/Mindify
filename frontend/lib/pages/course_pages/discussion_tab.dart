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
import 'package:getwidget/getwidget.dart';
import 'package:timeago/timeago.dart' as timeago;

class Discussion extends StatefulWidget {
  final String courseId;
  final bool isEnrolled;
  final bool isPreviewing;

  const Discussion({
    super.key,
    required this.courseId,
    required this.isEnrolled,
    required this.isPreviewing,
  });

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
  bool isLoading = true;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    userId = userService.getUserId();
  }

  @override
  void dispose() {
    _commentController.dispose();
    focusNode.dispose();
    super.dispose();
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
      bottomSheet: widget.isPreviewing
          ? const SizedBox.shrink()
          : Container(
              height: MediaQuery.of(context).size.height * 0.07,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: TextField(
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _replyToCommentId = null;
                  });
                },
                focusNode: focusNode,
                key: _commentFieldKey,
                controller: _commentController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.ghostWhite,
                  contentPadding: const EdgeInsets.all(12),
                  hintText: _replyToCommentId == null
                      ? 'Start a discussion...'
                      : 'Replying...',
                  border: InputBorder.none,
                  hintStyle: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(fontSize: 16),
                  suffixIcon: IconButton(
                    onPressed: _addComment,
                    icon: const Icon(
                      Icons.send,
                      color: AppColors.deepBlue,
                    ),
                  ),
                ),
              ),
            ),
      body: StreamBuilder<QuerySnapshot>(
          stream: commentService.getCommentsStreamByCourse(widget.courseId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const MyLoading(
                width: 30,
                height: 30,
                color: AppColors.deepBlue,
              );
            }
            List<DocumentSnapshot> commentDocs = snapshot.data!.docs;

            commentDocs.sort((a, b) {
              DateTime aCreatedAt = DateTime.parse(a['createdAt']);
              DateTime bCreatedAt = DateTime.parse(b['createdAt']);
              return bCreatedAt.compareTo(aCreatedAt);
            });

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
                            '${commentDocs.length} Discussions',
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
                            itemCount: commentDocs.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot doc = commentDocs[index];
                              String commentId = doc.id;
                              Map<String, dynamic> data =
                                  doc.data() as Map<String, dynamic>;

                              return FutureBuilder<Map<String, dynamic>>(
                                future: userService
                                    .getUserNameAndAvatar(data['userId']),
                                builder: (context, userSnapshot) {
                                  if (!userSnapshot.hasData) {
                                    return const SizedBox.shrink();
                                  }

                                  Map<String, dynamic> userData =
                                      userSnapshot.data!;
                                  String displayName =
                                      userData['displayName'] ??
                                          'Mindify Member';
                                  String photoUrl = userData['photoUrl'] ??
                                      'assets/images/default_avatar.png';

                                  return StreamBuilder<QuerySnapshot>(
                                      stream: commentService
                                          .getReplieStreamByComment(
                                              widget.courseId, commentId),
                                      builder: (context, replySnapshot) {
                                        if (!replySnapshot.hasData) {
                                          return const SizedBox.shrink();
                                        }
                                        List<DocumentSnapshot> replyDocs =
                                            replySnapshot.data!.docs;

                                        // Sắp xếp các trả lời theo createdAt từ mới nhất đến cũ nhất
                                        replyDocs.sort((a, b) {
                                          DateTime aCreatedAt =
                                              DateTime.parse(a['createdAt']);
                                          DateTime bCreatedAt =
                                              DateTime.parse(b['createdAt']);
                                          return bCreatedAt.compareTo(
                                              aCreatedAt);
                                        });

                                        List<Reply> replies = replyDocs
                                            .map(
                                              (doc) => Reply.fromJson(doc.data()
                                                  as Map<String, dynamic>),
                                            )
                                            .toList();

                                        Comment comment = Comment(
                                          id: commentId,
                                          content: data['content'],
                                          userId: data['userId'],
                                          createdAt: data['createdAt'],
                                          replies: replies,
                                        );

                                        return Column(
                                          children: [
                                            _buildCommentTree(context, comment,
                                                displayName, photoUrl),
                                            const Divider(
                                                color: AppColors.lighterGrey),
                                          ],
                                        );
                                      });
                                },
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
          }),
    );
  }

  Widget _buildCommentTree(BuildContext context, Comment rootComment,
      String rootDisplayName, String rootPhotoUrl) {
    return ct.CommentTreeWidget<Comment, Reply>(
      rootComment,
      rootComment.replies,
      treeThemeData:
          const ct.TreeThemeData(lineColor: AppColors.cream, lineWidth: 3),
      avatarRoot: (context, data) => PreferredSize(
        preferredSize: const Size.fromRadius(18),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey,
          backgroundImage: NetworkImage(rootPhotoUrl),
        ),
      ),
      avatarChild: (context, data) {
        return PreferredSize(
          preferredSize: const Size.fromRadius(12),
          child: FutureBuilder<Map<String, dynamic>>(
            future: userService.getUserNameAndAvatar(data.userId),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return const GFShimmer(
                  child: CircleAvatar(
                    radius: 12,
                  ),
                );
              }
              Map<String, dynamic> userData = userSnapshot.data!;
              String photoUrl = userData['photoUrl'];
              return CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(photoUrl),
              );
            },
          ),
        );
      },
      contentRoot: (context, data) {
        return _buildCommentContent(context, data, rootDisplayName,
            rootPhotoUrl, rootComment.createdAt);
      },
      contentChild: (context, data) {
        return FutureBuilder<Map<String, dynamic>>(
          future: userService.getUserNameAndAvatar(data.userId),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return const GFShimmer(
                child: ListTile(
                  title: Text(''),
                ),
              );
            }
            Map<String, dynamic> userData = userSnapshot.data!;
            String displayName = userData['displayName'] ?? 'Mindify Member';
            String photoUrl = userData['photoUrl'] ??
                'assets/images/default_avatar.png';

            return _buildReplyContent(context, data, displayName, photoUrl);
          },
        );
      },
    );
  }

  Widget _buildCommentContent(BuildContext context, Comment comment,
    String displayName, String photoUrl, String createdAt) {
  final DateTime createdAtDateTime = DateTime.parse(createdAt);
  final timeAgo = timeago.format(createdAtDateTime, locale: 'en');

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayName,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(fontWeight: FontWeight.w600, color: Colors.black),
            ),
            const SizedBox(height: 4),
            Text(
              comment.content,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(fontWeight: FontWeight.w300, color: Colors.black),
            ),
          ],
        ),
      ),
      DefaultTextStyle(
        style: Theme.of(context)
            .textTheme
            .bodySmall!
            .copyWith(color: Colors.grey[700], fontWeight: FontWeight.bold),
        child: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(
                timeAgo,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: AppColors.lightGrey),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: () {
                  focusNode.requestFocus();
                  setState(() {
                    _replyToCommentId = comment.id;
                  });
                },
                child: Text(
                  'Reply',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppColors.lightGrey),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _buildReplyContent(BuildContext context, Reply reply,
    String displayName, String photoUrl) {
  final DateTime createdAtDateTime = DateTime.parse(reply.createdAt);
  final timeAgo = timeago.format(createdAtDateTime, locale: 'en');

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayName,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(fontWeight: FontWeight.w600, color: Colors.black),
            ),
            const SizedBox(height: 4),
            Text(
              reply.content,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(fontWeight: FontWeight.w300, color: Colors.black),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          timeAgo,
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(color: AppColors.lightGrey),
        ),
      ),
    ],
  );
}

}
