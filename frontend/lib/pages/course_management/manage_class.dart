import 'dart:convert';
import 'dart:developer';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:frontend/pages/course_management/create_quiz.dart';
import 'package:frontend/pages/course_management/lesson_upload.dart';
import 'package:frontend/pages/course_management/preview_class.dart';
import 'package:frontend/pages/course_management/publish_course.dart';
import 'package:frontend/pages/course_pages/course_detail.dart';
import 'package:frontend/services/functions/QuizService.dart';
import 'package:frontend/utils/toasts.dart';
import 'package:frontend/widgets/multiline_tag.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/my_course.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter/foundation.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:collection/collection.dart';

class ManageClass extends StatefulWidget {
  final String courseId;
  final bool isEditing;
  const ManageClass({
    super.key,
    required this.courseId,
    required this.isEditing,
  });

  @override
  State<ManageClass> createState() => _ManageClassState();
}

class _ManageClassState extends State<ManageClass> {
  // Services
  CourseService courseServices = CourseService();
  QuizService quizService = QuizService();

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final QuillController _classDescriptionController = QuillController.basic();
  final QuillController _projectDescriptionController = QuillController.basic();
  final ScrollController _scrollController = ScrollController();
  late StringTagController stringTagController;
  int lessonNums = 0;

  // Variables
  String greeting = "Hello";
  String userName =
      FirebaseAuth.instance.currentUser!.displayName ?? "Mindify Member";
  late Course myCourse;
  late String courseTitle;
  late Future<Course> _future;
  final animationDuration = const Duration(milliseconds: 300);
  bool _isSaved = false;

  String getGrettings() {
    DateTime now = DateTime.now();
    String greeting = "";
    int hours = now.hour;

    if (hours >= 1 && hours <= 12) {
      greeting = "Good Morning";
    } else if (hours >= 12 && hours <= 16) {
      greeting = "Good Afternoon";
    } else if (hours >= 16 && hours <= 21) {
      greeting = "Good Evening";
    } else if (hours >= 21 && hours <= 24) {
      greeting = "Good Night";
    } else {
      greeting = "Hello";
    }

    return greeting;
  }

  List<String> _initialTags = <String>[];

  @override
  void initState() {
    super.initState();
    greeting = getGrettings();
    _future = getCourse();
    stringTagController = StringTagController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _classDescriptionController.dispose();
    _projectDescriptionController.dispose();
    stringTagController.dispose();
    super.dispose();
  }

  Future<Course> getCourse() async {
    await courseServices.getCourseById(widget.courseId).then((value) {
      myCourse = value;
      courseTitle = myCourse.title;
      _titleController.text = myCourse.title;
      _classDescriptionController.document = Document.fromJson(
        jsonDecode(myCourse.description),
      );

      _projectDescriptionController.document =
          Document.fromJson(jsonDecode(myCourse.projectDescription));
      _initialTags = myCourse.categories;
    });

    return myCourse;
  }

  Future<void> saveCourse() async {
    String classDescription =
        jsonEncode(_classDescriptionController.document.toDelta().toJson());
    String projectDescription =
        jsonEncode(_projectDescriptionController.document.toDelta().toJson());
    String title = _titleController.text;
    var updatedData = {
      "courseName": title,
      "projectDescription": projectDescription,
      "description": classDescription,
      "category": stringTagController.getTags ?? [],
    };

    await courseServices.updateCourse(widget.courseId, updatedData);
    myCourse.title = title;
    myCourse.projectDescription = projectDescription;
    myCourse.description = classDescription;
    myCourse.categories = stringTagController.getTags ?? [];
  }

  bool _onChanged(
      String classDescription, String projectDescription, String title) {
    Function eq = const ListEquality().equals;
    if (classDescription.trim() != myCourse.description.trim() ||
        projectDescription.trim() != myCourse.projectDescription.trim() ||
        title.trim() != myCourse.title.trim() ||
        !eq(stringTagController.getTags, myCourse.categories)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.deepBlue,
        leading: FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }
              return IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    String classDescription = jsonEncode(
                        _classDescriptionController.document
                            .toDelta()
                            .toJson());

                    String projectDescription = jsonEncode(
                      _projectDescriptionController.document.toDelta().toJson(),
                    );
                    String title = _titleController.text;
                    bool isModify =
                        _onChanged(classDescription, projectDescription, title);
                    Course? course = myCourse;

                    if (isModify) {
                      bool? shouldPop = await AwesomeDialog(
                        padding: const EdgeInsets.all(16),
                        context: context,
                        dialogType: DialogType.noHeader,
                        title: 'Unsaved Changes',
                        desc:
                            'You have unsaved changes. Do you really want to leave?',
                        btnCancelOnPress: () {},
                        btnOkOnPress: () {
                          Navigator.pop(context, true); // Pop with true value
                        },
                      ).show();

                      if (shouldPop == true && context.mounted) {
                        if (!widget.isEditing) {
                          Navigator.pop(context);
                        }
                        Navigator.pop(context, course);
                      }
                    } else {
                      if (!widget.isEditing) {
                        Navigator.pop(context);
                      }
                      Navigator.pop(context, course);
                    }
                  });
            }),
        titleSpacing: 0,
        title: Text(
          "$greeting, $userName",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              saveCourse();
              showSuccessToast(context, "Saved");
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                _isSaved ? "Saved" : "Save",
                style: const TextStyle(
                  color: AppColors.cream,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
        ],
      ),
      body: FutureBuilder(
        future: _future,
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
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          return SafeArea(
            child: Container(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            courseTitle,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                  color: Colors.black,
                                  fontSize: 20,
                                ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.mediumVertical,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.cream,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          child: const Text(
                            "Draft",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PreviewClass(
                                  courseId: widget.courseId,
                                  userId:
                                      FirebaseAuth.instance.currentUser!.uid,
                                ),
                              ),
                            );
                          },
                          child: RichText(
                            text: const TextSpan(
                              children: [
                                WidgetSpan(
                                  child: Icon(
                                    Icons.remove_red_eye,
                                    size: 16,
                                    color: AppColors.lightGrey,
                                  ),
                                ),
                                WidgetSpan(
                                  child: SizedBox(
                                    width: 3,
                                  ),
                                ),
                                TextSpan(
                                  text: "Preview Class",
                                  style: TextStyle(
                                    color: AppColors.deepBlue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    AppSpacing.smallVertical,
                    const Divider(),
                    StreamBuilder<QuerySnapshot>(
                        stream: courseServices
                            .getLessonStreamByCourse(widget.courseId),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            int lessonNum = snapshot.data!.docs.length;
                            lessonNums = lessonNum;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                "Video Lessons",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              trailing: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LessonUpload(
                                        courseId: widget.courseId,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Manage",
                                  style: TextStyle(
                                    color: AppColors.deepBlue,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              subtitle: Text("$lessonNum lesson(s)"),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }),
                    StreamBuilder<QuerySnapshot>(
                      stream:
                          quizService.getQuizzesStreamByCourse(widget.courseId),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          int quizNum = snapshot.data!.docs.length;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              "Quizzes (Optional)",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            trailing: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CreateQuiz(courseId: widget.courseId),
                                  ),
                                );
                              },
                              child: const Text(
                                "Manage",
                                style: TextStyle(
                                  color: AppColors.deepBlue,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            subtitle: Text("$quizNum quiz(s)"),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const Divider(),
                    AppSpacing.mediumVertical,
                    const Text(
                      "Class Title*",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const Text(
                      "Keep your title between 20 and 70 characters.",
                    ),
                    AppSpacing.mediumVertical,
                    TextFormField(
                      onTap: () {},
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      controller: _titleController,
                      onChanged: (value) {
                        setState(() {
                          courseTitle = value;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: AppColors.lightGrey,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: AppColors.deepBlue,
                          ),
                        ),
                      ),
                      cursorColor: Colors.black,
                    ),
                    AppSpacing.mediumVertical,
                    const Text(
                      "Class Description*",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const Text(
                      "Minimum 100 characters. Write specific details on what should be included in your class",
                    ),
                    AppSpacing.smallVertical,
                    _buildQuillToolbar(_classDescriptionController),
                    _buildQuillEditor(_classDescriptionController),
                    AppSpacing.mediumVertical,
                    const Text(
                      "Project Description*",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const Text(
                      "Minimum 100 characters. Craft a relevant and engaging project for your class",
                    ),
                    AppSpacing.smallVertical,
                    _buildQuillToolbar(_projectDescriptionController),
                    _buildQuillEditor(_projectDescriptionController),
                    AppSpacing.mediumVertical,
                    const Text(
                      "Class Categories*",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const Text(
                      "Class categories tags help students find your class. Add tags to make your class more discoverable in search results",
                    ),
                    AppSpacing.smallVertical,
                    MultilineTag(
                      controller: stringTagController,
                      initialTags: _initialTags,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              stringTagController.clearTags();
                            });
                          },
                          child: const Text(
                            'CLEAR ',
                            style: TextStyle(
                              color: AppColors.deepBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.mediumVertical,
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          proceedNext();
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(AppColors.cream),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        child: const Text(
                          "Next Step",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void proceedNext() {
    if (myCourse.title.isEmpty || myCourse.title == "") {
      showErrorToast(context, "Please enter a title");
      return;
    }
    if (myCourse.title.length < 20 || myCourse.title.length > 70) {
      showErrorToast(context, "Title must be between 20 and 70 characters");
      return;
    }
    if (myCourse.description.isEmpty || myCourse.description == "\n") {
      showErrorToast(context, "Please enter a class description");
      return;
    }
    if (myCourse.description.length < 100) {
      showErrorToast(
          context, "Class description must be at least 100 characters");
      return;
    }
    if (myCourse.projectDescription.isEmpty ||
        myCourse.projectDescription == "\n") {
      showErrorToast(context, "Please enter a project description");
      return;
    }
    if (myCourse.projectDescription.length < 100) {
      showErrorToast(
          context, "Project description must be at least 100 characters");
      return;
    }
    if (myCourse.categories.isEmpty) {
      showErrorToast(context, "Please enter at least one category");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PublishCourse(
          courseId: widget.courseId,
          lessonNums: lessonNums,
        ),
      ),
    );
  }

  Widget _buildQuillToolbar(QuillController controller) {
    return quill.QuillToolbar.simple(
      configurations: QuillSimpleToolbarConfigurations(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: AppColors.lightGrey,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        multiRowsDisplay: false,
        showSearchButton: false,
        showInlineCode: false,
        showFontFamily: false,
        showSubscript: false,
        showSuperscript: false,
        showStrikeThrough: false,
        showIndent: false,
        showQuote: false,
        showCodeBlock: false,
        controller: controller,
        sharedConfigurations: const QuillSharedConfigurations(
          locale: Locale('en'),
        ),
      ),
    );
  }

  Widget _buildQuillEditor(QuillController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.lightGrey,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.3,
      child: quill.QuillEditor.basic(
        configurations: QuillEditorConfigurations(
          onTapOutside: (event, focusNode) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          padding: const EdgeInsets.all(10),
          controller: controller,
          sharedConfigurations: const QuillSharedConfigurations(
            locale: Locale('en'),
          ),
        ),
      ),
    );
  }
}
