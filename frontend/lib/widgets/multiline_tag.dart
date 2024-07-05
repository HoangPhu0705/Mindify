import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:textfield_tags/textfield_tags.dart';

class MultilineTag extends StatefulWidget {
  final StringTagController controller;
  const MultilineTag({super.key, required this.controller});

  @override
  State<MultilineTag> createState() => _MultilineTagState();
}

class _MultilineTagState extends State<MultilineTag> {
  @override
  Widget build(BuildContext context) {
    return TextFieldTags<String>(
      textfieldTagsController: widget.controller,
      textSeparators: const [' ', ','],
      letterCase: LetterCase.normal,
      validator: (String tag) {
        if (widget.controller.getTags!.contains(tag)) {
          return 'You\'ve already entered that';
        }
        return null;
      },
      initialTags: const [],
      inputFieldBuilder: (context, inputFieldValues) {
        return TextField(
          onTap: () {
            widget.controller.getFocusNode?.requestFocus();
          },
          controller: inputFieldValues.textEditingController,
          focusNode: inputFieldValues.focusNode,
          decoration: InputDecoration(
            isDense: true,
            border: const OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.lightGrey,
                width: 1.0,
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.deepBlue,
                width: 1.0,
              ),
            ),
            hintText: inputFieldValues.tags.isNotEmpty ? '' : "Enter tag...",
            hintStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            errorText: inputFieldValues.error,
            prefixIcon: inputFieldValues.tags.isNotEmpty
                ? SingleChildScrollView(
                    controller: inputFieldValues.tagScrollController,
                    scrollDirection: Axis.vertical,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 8,
                        bottom: 8,
                        left: 8,
                      ),
                      child: Wrap(
                          runSpacing: 4.0,
                          spacing: 4.0,
                          children: inputFieldValues.tags.map((String tag) {
                            return Container(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                                color: AppColors.deepBlue,
                              ),
                              margin: const EdgeInsets.only(
                                right: 5,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    child: Text(
                                      '$tag',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    onTap: () {
                                      //print("$tag selected");
                                    },
                                  ),
                                  const SizedBox(width: 4.0),
                                  InkWell(
                                    child: const Icon(
                                      Icons.cancel,
                                      size: 14.0,
                                      color: Color.fromARGB(255, 233, 233, 233),
                                    ),
                                    onTap: () {
                                      inputFieldValues.onTagRemoved(tag);
                                    },
                                  )
                                ],
                              ),
                            );
                          }).toList()),
                    ),
                  )
                : null,
          ),
          onChanged: (tag) {
            inputFieldValues.onTagChanged(tag);
          },
          onSubmitted: (tag) {
            log("Submit $tag");
          },
        );
      },
    );
  }
}
