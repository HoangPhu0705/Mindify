import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/functions/QuizService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/widgets/my_loading.dart';

class QuizPage extends StatefulWidget {
  final String quizId;
  final String quizName;
  const QuizPage({
    super.key,
    required this.quizId,
    required this.quizName,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  //Services
  QuizService quizService = QuizService();

  //Variables
  PageController pageController = new PageController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            StreamBuilder<QuerySnapshot>(
              stream: quizService.getQuestionsStreamByQuiz(widget.quizId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: MyLoading(
                      width: 30,
                      height: 30,
                      color: AppColors.deepBlue,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Error"),
                  );
                }

                if (snapshot.hasData) {
                  List<DocumentSnapshot> questions = snapshot.data!.docs;
                  if (questions.isEmpty) {
                    return const Center(
                      child: Text("Your quiz don't have any questions"),
                    );
                  }

                  return Expanded(
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot question = questions[index];
                        String questionText = question["question"];
                        List<dynamic> wrongChoices = question["wrongChoices"];
                        List<dynamic> answers = question["answers"];

                        List<dynamic> options = [...wrongChoices, ...answers];

                        return Container(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Text(
                                question["question"],
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(options[index]),
                                    leading: Radio(
                                      value: options[index],
                                      groupValue: question["answers"],
                                      onChanged: (value) {},
                                    ),
                                  );
                                },
                              )
                            ],
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
}
