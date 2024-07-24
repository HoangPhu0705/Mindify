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
  final GlobalKey<VideoPlayerViewState> playerkey;
  const NoteTab({
    Key? key,
    required this.enrollmentId,
    required this.lessonId,
    required this.playerkey,
  }) : super(key: key);

  @override
  State<NoteTab> createState() => _NoteTabState();
}

class _NoteTabState extends State<NoteTab> {
  NoteService noteService = NoteService();

  Future<void> addNote() async {
    try {
      final noteId = await noteService.addNote(
        widget.enrollmentId,
        {
          'lessonId': widget.lessonId,
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
  }

  String convertTime(int time) {
    int minutes = time ~/ 60;
    int seconds = time % 60;
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        decoration: const BoxDecoration(
          color: AppColors.ghostWhite,
          border: Border(
            top: BorderSide(
              color: Colors.grey,
              width: 0.5,
            ),
          ),
        ),
        height: 60,
        child: Center(
          child: Container(
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
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
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
            StreamBuilder<QuerySnapshot>(
              stream: noteService.getNoteStream(widget.enrollmentId),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  List<DocumentSnapshot> notes = snapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot note = notes[index];
                      String noteId = note.id;
                      int time = note['time'];
                      String timeconverted = convertTime(time);
                      return ListTile(
                        title: Text('Note $index'),
                        subtitle: Text('Time: $timeconverted'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            noteService.deleteNote(
                              widget.enrollmentId,
                              noteId,
                            );
                          },
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
            )
          ],
        ),
      ),
    );
  }
}
