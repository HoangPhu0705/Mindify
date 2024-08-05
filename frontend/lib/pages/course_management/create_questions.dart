// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/functions/QuizService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/images.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/utils/toasts.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';

class CreateQuestions extends StatefulWidget {
  final String quizId;
  final String questionId;
  final int questionCount;
  CreateQuestions({
    Key? key,
    required this.quizId,
    required this.questionId,
    required this.questionCount,
  }) : super(key: key);

  @override
  State<CreateQuestions> createState() => _CreateQuestionsState();
}

class _CreateQuestionsState extends State<CreateQuestions> {
  //Variables
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? questionData;
  late Future<void> _future;
  String? questionImage;

  // Services
  QuizService quizzService = QuizService();
  final _questionController = TextEditingController();
  final _originalAnswerController = TextEditingController();
  final _originalWrongChoiceController = TextEditingController();
  final _explanationController = TextEditingController();

  // Controllers for answer fields
  final List<TextEditingController> _answerControllers = [];
  final List<TextEditingController> _wrongChoiceControllers = [];

  @override
  void initState() {
    super.initState();
    if (widget.questionId.isNotEmpty) {
      _future = _fetchQuestionDetail();
    }
  }

  @override
  void dispose() {
    for (var controller in _answerControllers) {
      controller.dispose();
    }

    for (var controller in _wrongChoiceControllers) {
      controller.dispose();
    }

    _questionController.dispose();
    _originalAnswerController.dispose();
    _originalWrongChoiceController.dispose();
    _explanationController.dispose();
    super.dispose();
  }

  void updateQuestionImage(Uint8List selectedImage) async {
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef =
        storageRef.child('question_image/question_${widget.questionId}');
    await imageRef.putData(selectedImage);
    var photoUrl = (await imageRef.getDownloadURL()).toString();
    setState(() {
      questionImage = photoUrl;
    });
    var imageData = {
      "questionImage": questionImage,
    };

    try {
      await quizzService.updateQuestion(
        widget.quizId,
        widget.questionId,
        imageData,
      );
    } catch (e) {
      showErrorToast(context, "Error adding image");
    }
  }

  void selectImageFromGallery() async {
    Uint8List selectedImage = await pickImage(ImageSource.gallery);
    if (widget.questionId.isNotEmpty) {
      updateQuestionImage(selectedImage);
    } else {
      showErrorToast(context, "Please create question first");
    }
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

  Future<void> _fetchQuestionDetail() async {
    questionData =
        await quizzService.getQuestionById(widget.quizId, widget.questionId);
    _questionController.text = questionData!["question"];
    List<dynamic> answers = questionData!["answers"];
    _originalAnswerController.text = answers[0];
    for (var i = 1; i < answers.length; i++) {
      _addAnswerField();
      _answerControllers[i - 1].text = answers[i];
    }
    List<dynamic> wrongChoices = questionData!["wrongChoices"];
    _originalWrongChoiceController.text = wrongChoices[0];
    for (var i = 1; i < wrongChoices.length; i++) {
      _addWrongChoiceField();
      _wrongChoiceControllers[i - 1].text = wrongChoices[i];
    }
    _explanationController.text = questionData!["explanation"];
    setState(() {
      questionImage = questionData!["questionImage"];
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
      "index": widget.questionCount,
      "question": question,
      "answers": answerList,
      "wrongChoices": wrongChoicesList,
      "explanation": explanation,
      "questionImage": questionImage,
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

  Future<void> updateQuestion() async {
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
      "questionImage": questionImage,
    };

    try {
      await quizzService.updateQuestion(
        widget.quizId,
        widget.questionId,
        questionData,
      );
      showSuccessToast(context, "Question editted");
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
                    if (widget.questionId.isEmpty) {
                      await addQuestion();
                    } else {
                      await updateQuestion();
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.questionId.isEmpty
                        ? "Create question"
                        : "Update question",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      appBar: AppBar(
        surfaceTintColor: AppColors.ghostWhite,
        backgroundColor: AppColors.ghostWhite,
        centerTitle: true,
        title: const Text(
          "Question detail",
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
                    () {
                      selectImageFromGallery();
                    },
                  ),
                  questionImage != null
                      ? Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.2,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    alignment: const Alignment(-.2, 0),
                                    image: NetworkImage(questionImage!),
                                    fit: BoxFit.cover),
                              ),
                              alignment: Alignment.bottomCenter,
                              padding: const EdgeInsets.only(bottom: 20),
                            ),
                            IconButton(
                              onPressed: () async {
                                var deleteImage = {
                                  "questionImage": null,
                                };

                                await quizzService.updateQuestion(
                                  widget.quizId,
                                  widget.questionId,
                                  deleteImage,
                                );
                                final storageRef =
                                    FirebaseStorage.instance.ref();
                                final questionImageRef = storageRef.child(
                                  "question_image/question_${widget.questionId}",
                                );
                                await questionImageRef.delete();
                                setState(() {
                                  questionImage = null;
                                });
                              },
                              icon: const Icon(Icons.delete),
                              color: Colors.red,
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
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
          onTapOutside: (event) {},
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
