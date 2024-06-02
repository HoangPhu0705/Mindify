// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';

class CourseCard extends StatefulWidget {
  final String thumbnail;
  final String instructor;
  final String specializaion;
  final String courseName;
  final int time;
  final int numberOfLesson;
  final String avatar;
  final Function()? onSavedPressed;

  const CourseCard({
    Key? key,
    required this.thumbnail,
    required this.instructor,
    required this.specializaion,
    required this.courseName,
    required this.time,
    required this.numberOfLesson,
    required this.avatar,
    this.onSavedPressed,
  }) : super(key: key);

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      width: 320,
      height: 400,
      child: Card(
        elevation: 4,
        shadowColor: Colors.black,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
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
                      padding: EdgeInsets.fromLTRB(10, 5, 0, 5),
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
                                widget.specializaion,
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
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "${widget.time}m",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.deepBlue,
                                    ),
                                  ),
                                  AppSpacing.smallHorizontal,
                                  Text(
                                    "•  ${widget.numberOfLesson} Lessons",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Icon(
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
