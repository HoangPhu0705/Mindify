import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/course_management/quiz_result.dart';
import 'package:frontend/services/functions/QuizService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:selectable_container/selectable_container.dart';

class QuizPage extends StatefulWidget {
  final String quizId;
  final String quizName;
  final int totalQuestion;
  const QuizPage({
    super.key,
    required this.quizId,
    required this.quizName,
    required this.totalQuestion,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  //Services
  QuizService quizService = QuizService();

  //Variables
  int currentPage = 0;
  Map<String, List<String>> selectedOptions = {};
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(
      initialPage: currentPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: widget.totalQuestion == 0
          ? const SizedBox.shrink()
          : Container(
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
                        if (currentPage < widget.totalQuestion - 1) {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        } else {
                          var result = getSelectedAnswers();
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => QuizResult(
                              result: result,
                              quizName: widget.quizName,
                              quizId: widget.quizId,
                            ),
                          ));
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          currentPage < widget.totalQuestion - 1
                              ? "Next"
                              : "Finish",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
      appBar: AppBar(
        title: Text(
          widget.quizName,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            widget.totalQuestion == 0
                ? const SizedBox.shrink()
                : LinearPercentIndicator(
                    padding: const EdgeInsets.all(0),
                    lineHeight: 10,
                    percent: (currentPage + 1) / (widget.totalQuestion),
                    progressColor: AppColors.blue,
                    backgroundColor: AppColors.lighterGrey,
                    animateFromLastPercent: true,
                    animation: true,
                    barRadius: const Radius.circular(10),
                    trailing: IconButton(
                      onPressed: () {
                        pageController.previousPage(
                          duration: const Duration(
                            milliseconds: 300,
                          ),
                          curve: Curves.easeIn,
                        );
                      },
                      icon: const Icon(
                        Icons.undo_rounded,
                        color: AppColors.deepBlue,
                      ),
                    ),
                  ),
            StreamBuilder<QuerySnapshot>(
              stream: quizService.getQuestionsStreamByQuiz(widget.quizId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Error"),
                  );
                }

                if (snapshot.hasData) {
                  List<DocumentSnapshot> questions = snapshot.data!.docs;
                  if (questions.isEmpty) {
                    return const Center(
                      child: Text(
                        textAlign: TextAlign.center,
                        "Your quiz doesn't have any questions",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
                      ),
                    );
                  }

                  return Expanded(
                    child: PageView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          currentPage = index;
                        });
                      },
                      controller: pageController,
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot question = questions[index];
                        String questionId = question.id;
                        String questionText = question["question"];
                        List<dynamic> wrongChoices = question["wrongChoices"];
                        List<dynamic> answers = question["answers"];
                        String questionImage = question["questionImage"] ?? "";
                        List<dynamic> options = [...wrongChoices, ...answers];
                        return SingleChildScrollView(
                          child: Container(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.height * 0.1,
                            ),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "Question no.${index + 1}: ",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                AppSpacing.mediumVertical,
                                questionImage.isEmpty
                                    ? const SizedBox.shrink()
                                    : Container(
                                        height: 300,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: DecorationImage(
                                            image: NetworkImage(questionImage),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                AppSpacing.mediumVertical,
                                Text(
                                  textAlign: TextAlign.center,
                                  questionText,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Divider(),
                                AppSpacing.mediumVertical,
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    String option = options[index];
                                    bool isSelected =
                                        selectedOptions[questionId]
                                                ?.contains(option) ??
                                            false;

                                    return buildOptionContainer(
                                      questionId,
                                      option,
                                      isSelected,
                                      answers.length == 1,
                                    );
                                  },
                                ),
                                AppSpacing.mediumVertical,
                                answers.length > 1
                                    ? const Text(
                                        "Note*: This question has more than one answer",
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
                return const Center(
                  child: Text("No data"),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget buildOptionContainer(
    String questionId,
    String option,
    bool isSelected,
    bool singleChoice,
  ) {
    return SelectableContainer(
      unselectedBorderColor: Colors.black,
      elevation: 0,
      selectedBackgroundColor: Colors.transparent,
      selectedBorderColor: Colors.black,
      unselectedBackgroundColor: Colors.transparent,
      selectedBorderColorIcon: Colors.black,
      selectedBackgroundColorIcon: Colors.black,
      selected: isSelected,
      opacityAnimationDuration: 100,
      child: buildTextContentOfContainer(option),
      onValueChanged: (newValue) {
        setState(() {
          if (singleChoice) {
            if (newValue) {
              selectedOptions[questionId] = [option];
            }
          } else {
            if (newValue) {
              if (selectedOptions[questionId] == null) {
                selectedOptions[questionId] = [option];
              } else {
                selectedOptions[questionId]!.add(option);
              }
            } else {
              selectedOptions[questionId]?.remove(option);
            }
          }
        });
      },
    );
  }

  Widget buildTextContentOfContainer(String option) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          option,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Map<String, List<String>> getSelectedAnswers() {
    return selectedOptions;
  }
}
