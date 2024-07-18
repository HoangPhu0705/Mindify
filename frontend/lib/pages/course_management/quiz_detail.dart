import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/course_management/create_questions.dart';
import 'package:frontend/services/functions/QuizService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:getwidget/getwidget.dart';

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
  //Services
  QuizService quizService = QuizService();

  //Variables
  bool isEditting = false;
  final quizNameController = TextEditingController();
  FocusNode focusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
                        ? Form(
                            key: _formKey,
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Quiz name cannot be empty";
                                }
                                return null;
                              },
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
                            ),
                          )
                        : Text(
                            quizNameController.text,
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
                      } else {
                        String newName = quizNameController.text;
                        var data = {
                          "name": newName,
                        };

                        //Update the quiz name
                        if (_formKey.currentState!.validate()) {
                          quizService.updateQuiz(widget.quizId, data);
                          setState(() {});
                        } else {
                          setState(() {
                            isEditting = true;
                          });
                        }
                      }
                    },
                    icon: isEditting
                        ? const Text(
                            "Done",
                            style: TextStyle(
                              color: AppColors.deepBlue,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          )
                        : const Icon(
                            Icons.edit,
                            size: 20,
                          ),
                  )
                ],
              ),
              AppSpacing.mediumVertical,
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Questions List",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GFButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return CreateQuestions(
                              quizId: widget.quizId,
                            );
                          },
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.add,
                      size: 20,
                    ),
                    shape: GFButtonShape.pills,
                    type: GFButtonType.outline2x,
                    borderSide: const BorderSide(
                      color: Colors.black,
                    ),
                    color: AppColors.ghostWhite,
                    text: "Add",
                    textStyle: const TextStyle(
                      fontFamily: "Poppins",
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: quizService.getQuestionsStreamByQuiz(widget.quizId),
                  builder: (context, snapshot) {
                    List<DocumentSnapshot> documents = snapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot question = documents[index];
                        String questionId = question.id;
                        Map<String, dynamic> questionData =
                            question.data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(
                            questionData["question"],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                        );
                      },
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
