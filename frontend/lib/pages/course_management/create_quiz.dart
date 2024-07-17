import 'dart:developer';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:frontend/pages/course_management/quiz_detail.dart';
import 'package:frontend/services/functions/QuizService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/utils/toasts.dart';
import 'package:getwidget/getwidget.dart';
import 'package:googleapis/chat/v1.dart';

class CreateQuiz extends StatefulWidget {
  final String courseId;

  const CreateQuiz({super.key, required this.courseId});

  @override
  State<CreateQuiz> createState() => _CreateQuizState();
}

class _CreateQuizState extends State<CreateQuiz> {
  final TextEditingController _quizNameController = TextEditingController();
  final quizService = QuizService();

  @override
  void initState() {
    super.initState();
  }

  void _showAddQuizBottomSheet(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.bottomSlide,
      btnOkText: "Create",
      btnOkColor: AppColors.deepSpace,
      btnCancelOnPress: () {},
      dialogBorderRadius: BorderRadius.circular(5),
      body: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            const Text(
              "Enter your quiz name",
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
              ),
            ),
            TextField(
              controller: _quizNameController,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: AppColors.blue,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: AppColors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      btnOkOnPress: () async {
        String quizName = _quizNameController.text;
        if (quizName.isNotEmpty) {
          Map<String, dynamic> quizData = {
            'name': quizName,
            'courseId': widget.courseId,
          };
          String? quizId = await quizService.createQuiz(quizData);
          if (quizId != null) {
            _quizNameController.clear();
            showSuccessToast(context, "Quiz created successfully.");
          } else {
            showErrorToast(context, "Failed to create quiz.");
          }
        } else {
          showErrorToast(context, "Quiz name cannot be empty.");
        }
      },
    ).show();
  }

  @override
  void dispose() {
    _quizNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Quiz maker',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GFButton(
                size: 50,
                onPressed: () {
                  _showAddQuizBottomSheet(context);
                },
                text: "Create new",
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontFamily: "Poppins",
                  fontSize: 18,
                ),
                elevation: 5,
                borderSide: const BorderSide(
                  color: Colors.black,
                ),
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Colors.black,
                ),
                color: AppColors.ghostWhite,
                shape: GFButtonShape.pills,
              ),
              AppSpacing.mediumVertical,
              StreamBuilder<QuerySnapshot>(
                  stream: quizService.getQuizzesStreamByCourse(widget.courseId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<DocumentSnapshot> quizzes = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: quizzes.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot document = quizzes[index];
                          String quizId = document.id;
                          Map<String, dynamic> data =
                              quizzes[index].data() as Map<String, dynamic>;
                          String quizName = data['name'];
                          return Slidable(
                            key: ValueKey(quizId),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              dragDismissible: false,
                              children: [
                                SlidableAction(
                                  onPressed: (context) async {
                                    await quizService.deleteQuiz(quizId);
                                    showSuccessToast(context, "Quiz deleted");
                                  },
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.red,
                                  icon: Icons.delete,
                                  label: "Delete",
                                ),
                              ],
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: AppColors.ghostWhite,
                                border: const Border(
                                  top: BorderSide(
                                      color: AppColors.deepSpace, width: 1),
                                  left: BorderSide(
                                      color: AppColors.deepSpace, width: 1),
                                  bottom: BorderSide(
                                      color: AppColors.deepSpace, width: 5),
                                  right: BorderSide(
                                      color: AppColors.deepSpace, width: 4),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) {
                                      return QuizDetail(
                                        quizId: quizId,
                                        quizName: quizName,
                                      );
                                    }),
                                  );
                                },
                                splashColor: Colors.transparent,
                                leading: const Icon(
                                  Icons.quiz_outlined,
                                  color: AppColors.deepSpace,
                                  size: 30,
                                ),
                                title: Text(quizName),
                                subtitle: Text('Questions: 0'),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
