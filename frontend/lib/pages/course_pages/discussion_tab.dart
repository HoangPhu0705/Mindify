// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last

import 'dart:developer';

import 'package:comment_tree/comment_tree.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';

class Discussion extends StatefulWidget {
  const Discussion({super.key});

  @override
  State<Discussion> createState() => _DiscussionState();
}

class _DiscussionState extends State<Discussion> {
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
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.ghostWhite,
            contentPadding: EdgeInsets.all(12),
            hintText: 'Start a discussion...',
            border: InputBorder.none,
            hintStyle:
                Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 16),
            suffixIcon: IconButton(
              onPressed: () {
                log('Comment submitted');
              },
              icon: Icon(Icons.send, color: AppColors.deepBlue),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(
              8, 12, 8, MediaQuery.of(context).size.height * 0.07),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  '4 Discussions',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              AppSpacing.mediumVertical,
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      _buildCommentTree(
                        context,
                        Comment(
                          avatar: 'null',
                          userName: 'Hiếu Phạm',
                          content: 'This course is great !!',
                        ),
                        [
                          Comment(
                            avatar: 'null',
                            userName: 'Phú Phan',
                            content: 'Thank you',
                          ),
                        ],
                      ),
                      Divider(
                        color: AppColors.lighterGrey,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentTree(
      BuildContext context, Comment rootComment, List<Comment> replies) {
    return CommentTreeWidget<Comment, Comment>(
      rootComment,
      replies,
      treeThemeData: TreeThemeData(lineColor: AppColors.cream, lineWidth: 3),
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

      //Root
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
                    '${data.userName}',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  AppSpacing.smallVertical,
                  Text(
                    '${data.content}',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.w300, color: Colors.black),
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
                    Text('Reply'),
                  ],
                ),
              ),
            )
          ],
        );
      },

      //Reply comments
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
                    '${data.userName}',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  AppSpacing.smallVertical,
                  Text(
                    '${data.content}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w300, color: Colors.black),
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
                    Text('Reply'),
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
