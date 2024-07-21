import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/functions/QuizService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class QuizResult extends StatefulWidget {
  final Map<String, List<String>> result;
  final String quizName;
  final String quizId;

  const QuizResult({
    super.key,
    required this.result,
    required this.quizName,
    required this.quizId,
  });

  @override
  State<QuizResult> createState() => _QuizResultState();
}

class _QuizResultState extends State<QuizResult> {
  //Services
  QuizService quizService = QuizService();

  //Variables
  int correctCount = 0;
  double correctRate = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    calculateCorrectAnswers();
  }

  Future<void> calculateCorrectAnswers() async {
    final questions = await quizService.getQuestionByQuizzId(widget.quizId);
    Map<String, List<String>> correctAnswers = {};

    for (var question in questions) {
      List<dynamic> answers = question["answers"];
      correctAnswers[question["id"]] =
          answers.map((answer) => answer as String).toList();
    }

    log('Correct Answers: ${correctAnswers.toString()}');
    log('User Answers: ${widget.result.toString()}');

    int count = 0;

    widget.result.forEach((questionId, userAnswers) {
      List<String>? correctAnswerList = correctAnswers[questionId];
      if (correctAnswerList != null) {
        // Assuming userAnswers is also a List<String>
        if (correctAnswerList.every((answer) => userAnswers.contains(answer)) &&
            userAnswers.every((answer) => correctAnswerList.contains(answer))) {
          count++;
        }
      }
    });
    setState(() {
      correctCount = count;
      correctRate = ((correctCount / questions.length) * 100).roundToDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ghostWhite,
      appBar: AppBar(
        surfaceTintColor: AppColors.ghostWhite,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.close,
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Answer Result',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: quizService.getQuestionsStreamByQuiz(widget.quizId),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<DocumentSnapshot> questions = snapshot.data!.docs;

                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.deepBlue,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                widget.quizName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              AppSpacing.mediumVertical,
                              LinearPercentIndicator(
                                lineHeight: 10,
                                percent: correctRate / 100,
                                progressColor: AppColors.blue,
                                animateFromLastPercent: true,
                              ),
                              AppSpacing.mediumVertical,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Question count: ${questions.length}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  AppSpacing.smallHorizontal,
                                  Text(
                                    "Correct count: $correctCount",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  AppSpacing.smallHorizontal,
                                  Text(
                                    "Correct rate: $correctRate%",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.mediumVertical,
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: questions.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot question = questions[index];
                            List<String> userAnswers;
                            if (widget.result.containsKey(question.id)) {
                              userAnswers = widget.result[question.id]!;
                            } else {
                              userAnswers = [];
                            }

                            List<dynamic> wrongChoices =
                                question["wrongChoices"];
                            List<dynamic> answers = question["answers"];
                            List<dynamic> options = [
                              ...wrongChoices,
                              ...answers
                            ];
                            bool isCorrect;
                            if (answers.length == userAnswers.length) {
                              isCorrect = answers.every(
                                  (element) => userAnswers.contains(element));
                            } else {
                              isCorrect = false;
                            }
                            String explanation = question["explanation"];

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.lightGrey,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 7,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "${question['question']}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  AppSpacing.mediumVertical,

                                  ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: options.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Text(
                                          options[index],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        leading:
                                            answers.contains(options[index])
                                                ? const Icon(
                                                    Icons.check,
                                                    color: Colors.green,
                                                  )
                                                : const Icon(
                                                    Icons.close,
                                                    color: Colors.red,
                                                  ),
                                      );
                                    },
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "Your answer: ${userAnswers.join(", ").isEmpty ? "No answer" : userAnswers.join(", ")}",
                                        style: isCorrect
                                            ? const TextStyle(
                                                color: Colors.green,
                                              )
                                            : const TextStyle(
                                                color: Colors.red,
                                              ),
                                      ),
                                      isCorrect
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.green,
                                            )
                                          : const Icon(
                                              Icons.close,
                                              color: Colors.red,
                                            ),
                                    ],
                                  ),
                                  AppSpacing.mediumVertical,
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      textAlign: TextAlign.left,
                                      "Explanation: $explanation",
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
