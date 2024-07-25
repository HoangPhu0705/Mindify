import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:pie_menu/pie_menu.dart';

class MyClassItem extends StatefulWidget {
  final String classTitle;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;
  final String thumbnail;
  final bool isPublic;
  final bool requestSent;
  const MyClassItem(
      {super.key,
      required this.classTitle,
      required this.onEditPressed,
      required this.onDeletePressed,
      required this.thumbnail,
      required this.isPublic,
      required this.requestSent});

  @override
  State<MyClassItem> createState() => _MyClassItemState();
}

class _MyClassItemState extends State<MyClassItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: MediaQuery.of(context).size.width * 0.7,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Flexible(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: widget.thumbnail.isNotEmpty
                      ? NetworkImage(widget.thumbnail) as ImageProvider<Object>
                      : const AssetImage("assets/images/default_avatar.png")
                          as ImageProvider<Object>,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          AppSpacing.smallVertical,
          Flexible(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.classTitle,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis),
                      maxLines: 2,
                    ),
                  ),
                  PieMenu(
                    actions: [
                      PieAction.builder(
                        buttonTheme: const PieButtonTheme(
                          backgroundColor: AppColors.blue,
                          iconColor: Colors.black,
                        ),
                        tooltip: const Text(''),
                        onSelect: widget.onEditPressed,
                        builder: (hovered) {
                          return const Icon(Icons.edit);
                        },
                      ),
                      PieAction.builder(
                        buttonTheme: const PieButtonTheme(
                          backgroundColor: AppColors.blue,
                          iconColor: Colors.red,
                        ),
                        tooltip: const Text(''),
                        onSelect: widget.onDeletePressed,
                        builder: (hovered) {
                          return const Icon(
                            Icons.delete,
                          );
                        },
                      ),
                    ],
                    child: const Icon(
                      Icons.more_horiz,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!widget.isPublic)
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: const EdgeInsets.only(left: 5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                child: Text(
                  widget.requestSent ? "Pending" : "Draft",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: const EdgeInsets.only(left: 5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                child: const Text(
                  "Published",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
