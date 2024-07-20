import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/course_management/create_questions.dart';
import 'package:frontend/pages/course_management/quiz_page.dart';
import 'package:frontend/services/functions/QuizService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/my_loading.dart';
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
  QuizService quizzService = QuizService();

  //Variables
  bool isEditting = false;
  final quizNameController = TextEditingController();
  FocusNode focusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int totalQuestions = 0;

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

  void reorderData(List<DocumentSnapshot> list, int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final DocumentSnapshot item = list.removeAt(oldIndex);
      list.insert(newIndex, item);

      for (int i = 0; i < list.length; i++) {
        updateQuestionIndex(list[i].id, i);
      }
    });
  }

  Future<void> updateQuestionIndex(String questionId, int newIndex) async {
    await FirebaseFirestore.instance
        .collection('quizzes')
        .doc(widget.quizId)
        .collection('questions')
        .doc(questionId)
        .update({'index': newIndex});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.ghostWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              offset: const Offset(0, -1),
            ),
          ],
        ),
        height: MediaQuery.of(context).size.height * 0.1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppSpacing.mediumHorizontal,
            Expanded(
              child: TextButton(
                style: AppStyles.primaryButtonStyle,
                onPressed: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return QuizPage(
                          quizId: widget.quizId,
                          quizName: quizNameController.text,
                          totalQuestion: totalQuestions + 1,
                        );
                      },
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Preview",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, totalQuestions + 1);
          },
          icon: const Icon(
            Icons.chevron_left,
            size: 32,
          ),
        ),
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
                          quizzService.updateQuiz(widget.quizId, data);
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
                              questionId: "",
                              questionCount: totalQuestions + 1,
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
                  stream: quizzService.getQuestionsStreamByQuiz(widget.quizId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<DocumentSnapshot> documents = snapshot.data!.docs;
                      totalQuestions = documents.length - 1;
                      return ReorderableListView.builder(
                        onReorder: (oldIndex, newIndex) {
                          reorderData(documents, oldIndex, newIndex);
                        },
                        shrinkWrap: true,
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot question = documents[index];
                          String questionId = question.id;
                          Map<String, dynamic> questionData =
                              question.data() as Map<String, dynamic>;
                          List<dynamic> answers = questionData["answers"];
                          String answersText = answers.join(", ");
                          return ListTile(
                            key: ValueKey(questionId),
                            leading: Text(
                              "${index + 1}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            title: Text(
                              questionData["question"],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              "Answers: $answersText",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                _buildBottomSheet(
                                  context,
                                  questionId,
                                );
                              },
                              icon: const Icon(Icons.more_horiz),
                            ),
                          );
                        },
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }

  void _buildBottomSheet(BuildContext context, String questionId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.deepSpace,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(10),
            ),
          ),
          height: MediaQuery.of(context).size.height * 0.15,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.edit,
                  color: AppColors.cream,
                ),
                title: const Text(
                  'Edit',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);

                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return CreateQuestions(
                          quizId: widget.quizId,
                          questionId: questionId,
                          questionCount: totalQuestions + 1,
                        );
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete,
                  color: AppColors.cream,
                ),
                title: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  // Handle delete action
                  quizzService.deleteQuestion(widget.quizId, questionId);
                  Navigator.pop(context);
                  // Add your delete logic here
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
