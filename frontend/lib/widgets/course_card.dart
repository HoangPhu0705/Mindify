// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';

class CourseCard extends StatefulWidget {
  final String thumbnail;
  final String instructor;
  final String specialization;
  final String courseName;
  final String time;
  final int numberOfLesson;
  final String avatar;
  final VoidCallback onSavePressed;

  const CourseCard({
    Key? key,
    required this.thumbnail,
    required this.instructor,
    required this.specialization,
    required this.courseName,
    required this.time,
    required this.numberOfLesson,
    required this.avatar,
    required this.onSavePressed,
  }) : super(key: key);

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 400,
      child: Card(
        elevation: 4,
        shadowColor: Colors.black,
        surfaceTintColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(widget.thumbnail),
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Column(
                children: [
                  Flexible(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(widget.avatar),
                          ),
                          AppSpacing.mediumHorizontal,
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.instructor,
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              Text(
                                widget.specialization,
                                style: TextStyle(fontSize: 14),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.courseName,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(
                                  overflow: TextOverflow.ellipsis,
                                ),
                            maxLines: 2,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    widget.time,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.deepBlue,
                                    ),
                                  ),
                                  AppSpacing.smallHorizontal,
                                  Text(
                                    "•  ${widget.numberOfLesson} Lessons",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: widget.onSavePressed, // Gọi callback khi nhấn vào biểu tượng
                                child: const Icon(
                                  Icons.bookmark_border_outlined,
                                  size: 28,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
