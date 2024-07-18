// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frontend/services/functions/QuizService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/utils/toasts.dart';
import 'package:getwidget/getwidget.dart';

class CreateQuestions extends StatefulWidget {
  final String quizId;
  const CreateQuestions({
    Key? key,
    required this.quizId,
  }) : super(key: key);

  @override
  State<CreateQuestions> createState() => _CreateQuestionsState();
}

class _CreateQuestionsState extends State<CreateQuestions> {
  //Variables
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Services
  QuizService quizzService = QuizService();
  final _questionController = TextEditingController();
  final _originalAnswerController = TextEditingController();
  final _originalWrongChoiceController = TextEditingController();
  final _explanationController = TextEditingController();

  // Controllers for answer fields
  List<TextEditingController> _answerControllers = [];
  List<TextEditingController> _wrongChoiceControllers = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in _answerControllers) {
      controller.dispose();
    }

    for (var controller in _wrongChoiceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addAnswerField() {
    setState(() {
      _answerControllers.add(TextEditingController());
    });
  }

  void _addWrongChoiceField() {
    setState(() {
      _wrongChoiceControllers.add(TextEditingController());
    });
  }

  void _removeAnswerField(int index) {
    setState(() {
      _answerControllers[index].dispose();
      _answerControllers.removeAt(index);
    });
  }

  void _removeWrongChoiceField(int index) {
    setState(() {
      _wrongChoiceControllers[index].dispose();
      _wrongChoiceControllers.removeAt(index);
    });
  }

  Future<void> addQuestion() async {
    String question = _questionController.text;
    String originalAnswer = _originalAnswerController.text;
    String originalChoice = _originalWrongChoiceController.text;
    String explanation = _explanationController.text;
    List<String> answerList = [originalAnswer];
    List<String> wrongChoicesList = [originalChoice];

    for (var answers in _answerControllers) {
      answerList.add(answers.text);
    }

    for (var wrong in _wrongChoiceControllers) {
      wrongChoicesList.add(wrong.text);
    }

    var questionData = {
      "question": question,
      "answers": answerList,
      "wrongChoices": wrongChoicesList,
      "explanation": explanation,
    };

    try {
      await quizzService.addQuestionsToQuiz(
        widget.quizId,
        questionData,
      );
      showSuccessToast(context, "Question added successfully");
      Navigator.pop(context);
    } catch (e) {
      showErrorToast(context, "Error adding question");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ghostWhite,
      resizeToAvoidBottomInset: true,
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
                  if (_formKey.currentState!.validate()) {
                    await addQuestion();
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Create question",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      appBar: AppBar(
        surfaceTintColor: AppColors.ghostWhite,
        centerTitle: true,
        title: const Text(
          "Create question",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.1),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildLabel(
                    "Question",
                    true,
                    "Select Image",
                    Icons.add_a_photo,
                    () {},
                  ),
                  _buildField(_questionController),
                  _buildLabel(
                    "Answers",
                    true,
                    "Add",
                    Icons.add,
                    _addAnswerField,
                  ),
                  _buildField(_originalAnswerController),
                  AppSpacing.smallVertical,
                  ..._buildAnswerFields(),
                  _buildLabel(
                    "Wrong choices",
                    true,
                    "Add",
                    Icons.add,
                    _addWrongChoiceField,
                  ),
                  _buildField(_originalWrongChoiceController),
                  AppSpacing.smallVertical,
                  ..._buildWrongChoiceFields(),
                  _buildLabel(
                    "Explanation",
                    false,
                    "",
                    Icons.add,
                    () {},
                  ),
                  _buildField(_explanationController),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String title, bool haveButton, String buttonText,
      IconData icon, Function() action) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          haveButton
              ? buildButton(
                  buttonText,
                  icon,
                  action,
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSpacing.smallVertical,
        TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return "Please fill in the field";
            }
            return null;
          },
          controller: controller,
          style: const TextStyle(
            fontSize: 16.0,
            height: 1.0,
            color: Colors.black,
          ),
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(
                color: AppColors.lightGrey,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(
                color: AppColors.blue,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerField(int index) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please fill in the field";
                  }
                  return null;
                },
                controller: _answerControllers[index],
                style: const TextStyle(
                  fontSize: 16.0,
                  height: 1.0,
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      color: AppColors.lightGrey,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      color: AppColors.blue,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _removeAnswerField(index),
            ),
          ],
        ),
        AppSpacing.smallVertical,
      ],
    );
  }

  Widget _buildWrongChoiceField(int index) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please fill in the field";
                  }
                  return null;
                },
                controller: _wrongChoiceControllers[index],
                style: const TextStyle(
                  fontSize: 16.0,
                  height: 1.0,
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      color: AppColors.lightGrey,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      color: AppColors.blue,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _removeWrongChoiceField(index),
            ),
          ],
        ),
        AppSpacing.smallVertical,
      ],
    );
  }

  List<Widget> _buildAnswerFields() {
    return List<Widget>.generate(_answerControllers.length, (index) {
      return _buildAnswerField(index);
    });
  }

  List<Widget> _buildWrongChoiceFields() {
    return List<Widget>.generate(_wrongChoiceControllers.length, (index) {
      return _buildWrongChoiceField(index);
    });
  }

  Widget buildButton(String title, IconData icon, Function() action) {
    return GFButton(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 10,
      ),
      onPressed: action,
      icon: Icon(
        icon,
        size: 18,
      ),
      shape: GFButtonShape.pills,
      type: GFButtonType.outline2x,
      borderSide: const BorderSide(
        color: Colors.black,
      ),
      color: AppColors.ghostWhite,
      text: title,
      textStyle: const TextStyle(
        fontFamily: "Poppins",
        color: Colors.black,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }
}
