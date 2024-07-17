import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';

class QuizDetail extends StatefulWidget {
  final String quizId;
  final String quizName;
  const QuizDetail({
    super.key,
    required this.quizId,
    required this.quizName,
  });

  @override
  State<QuizDetail> createState() => _QuizDetailState();
}

class _QuizDetailState extends State<QuizDetail> {
  //Variables
  bool isEditting = false;
  final quizNameController = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    quizNameController.text = widget.quizName;
  }

  @override
  void dispose() {
    focusNode.dispose();
    quizNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit quiz",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      backgroundColor: AppColors.ghostWhite,
      body: Container(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: isEditting
                        ? TextField(
                            focusNode: focusNode,
                            controller: quizNameController,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.blue,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            widget.quizName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isEditting = !isEditting;
                      });

                      if (isEditting) {
                        focusNode.requestFocus();
                      }
                    },
                    icon: const Icon(
                      Icons.edit,
                      size: 20,
                    ),
                  )
                ],
              ),
              AppSpacing.mediumVertical,
            ],
          ),
        ),
      ),
    );
  }
}
