import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';

class MyCourseItem extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String author;
  final String duration;
  final String students;
  final VoidCallback? moreOnPress;

  const MyCourseItem(
      {required this.imageUrl,
      required this.title,
      required this.author,
      required this.duration,
      required this.students,
      required this.moreOnPress});

  @override
  State<MyCourseItem> createState() => _MyCourseItemState();
}

class _MyCourseItemState extends State<MyCourseItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                width: 100,
                height: 60,
              ),
              AppSpacing
                  .mediumHorizontal, // Add some space between the image and the text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    Text(widget.author),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.mediumVertical,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timer_sharp,
                    size: 20,
                  ),
                  Text("${widget.duration}  •"),
                  AppSpacing.smallHorizontal,
                  Icon(
                    Icons.person_2_outlined,
                    size: 20,
                  ),
                  Text("${widget.students}"),
                ],
              ),
              IconButton(
                onPressed: widget.moreOnPress,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: Icon(
                  Icons.more_horiz_outlined,
                  size: 32,
                ),
              )
            ],
          ),
          Divider(),
        ],
      ),
    );
  }
}
