// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/functions/NoteService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/video_player_view.dart';

class NoteTab extends StatefulWidget {
  final String enrollmentId;
  final String lessonId;
  final int lessonIndex;
  final String lessonTitle;
  final String lessonUrl;
  final GlobalKey<VideoPlayerViewState> playerkey;
  final void Function(String, int, int) onNoteTap;
  const NoteTab({
    Key? key,
    required this.enrollmentId,
    required this.lessonId,
    required this.playerkey,
    required this.lessonTitle,
    required this.lessonIndex,
    required this.onNoteTap,
    required this.lessonUrl,
  }) : super(key: key);

  @override
  State<NoteTab> createState() => _NoteTabState();
}

class _NoteTabState extends State<NoteTab> {
  NoteService noteService = NoteService();
  final noteController = TextEditingController();
  String? editingNoteId;
  FocusNode noteFocusNode = FocusNode();

  Future<void> addNote() async {
    try {
      final noteId = await noteService.addNote(
        widget.enrollmentId,
        {
          'content': "Your note",
          'lessonId': widget.lessonId,
          'lessonTitle': widget.lessonTitle,
          'lessonIndex': widget.lessonIndex,
          'lessonLink': widget.lessonUrl,
          'time': widget.playerkey.currentState!.getCurrentTime(),
        },
      );
      log('Note added: $noteId');
    } catch (e) {
      log('Failed to add note: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    noteFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    noteFocusNode.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!noteFocusNode.hasFocus && editingNoteId != null) {
      noteService.updateNote(
        widget.enrollmentId,
        editingNoteId!,
        {'content': noteController.text},
      );
      setState(() {
        editingNoteId = null;
      });
    }
  }

  String convertTime(int time) {
    int minutes = time ~/ 60;
    int seconds = time % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: AppColors.deepBlue,
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      onTap: () async {
                        await addNote();
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add,
                            color: AppColors.deepBlue,
                          ),
                          Text(
                            'Add note',
                            style: TextStyle(
                              color: AppColors.deepBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              StreamBuilder<QuerySnapshot>(
                stream: noteService.getNoteStream(widget.enrollmentId),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    List<DocumentSnapshot> notes = snapshot.data!.docs;
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot note = notes[index];
                        String noteId = note.id;
                        String content = note["content"];
                        int lessonIndex = note["lessonIndex"];
                        String lessonLink = note["lessonLink"];
                        String lessonTitle = note['lessonTitle'];
                        int time = note['time'];
                        String timeconverted = convertTime(time);
                        return ListTile(
                          onTap: () {
                            widget.onNoteTap(lessonLink, lessonIndex, time);
                          },
                          leading: const Icon(
                            Icons.note_alt,
                            color: AppColors.deepBlue,
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              editingNoteId == noteId
                                  ? TextField(
                                      maxLines: null,
                                      controller: noteController,
                                      focusNode: noteFocusNode,
                                    )
                                  : Text(
                                      content,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                              const SizedBox(height: 5),
                              Text(
                                '${lessonTitle}',
                                style: const TextStyle(
                                  color: AppColors.lightGrey,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '$timeconverted',
                                style: const TextStyle(
                                  color: AppColors.lightGrey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                focusNode: noteFocusNode,
                                onPressed: () async {
                                  if (editingNoteId == null) {
                                    setState(() {
                                      editingNoteId = noteId;
                                      noteController.text = content;
                                      noteFocusNode.requestFocus();
                                    });
                                  } else {
                                    await noteService.updateNote(
                                      widget.enrollmentId,
                                      noteId,
                                      {'content': noteController.text},
                                    );
                                    setState(() {
                                      editingNoteId = null;
                                    });
                                  }
                                },
                                icon: editingNoteId == noteId
                                    ? const Icon(
                                        Icons.done_outlined,
                                        size: 20,
                                        color: AppColors.deepSpace,
                                      )
                                    : const Icon(
                                        Icons.edit,
                                        size: 20,
                                        color: AppColors.deepSpace,
                                      ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  noteService.deleteNote(
                                    widget.enrollmentId,
                                    noteId,
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text('No notes added yet'),
                    );
                  }
                },
              ),
              // const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
