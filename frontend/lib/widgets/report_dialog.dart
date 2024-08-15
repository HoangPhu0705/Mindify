import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frontend/services/functions/ReportService.dart';
import 'package:frontend/utils/colors.dart';

class ReportDialog extends StatefulWidget {
  final String courseId;
  final String courseTitle;
  final String authorId;

  const ReportDialog({
    super.key,
    required this.courseId,
    required this.courseTitle,
    required this.authorId,
  });

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? _selectedReason;
  TextEditingController _customReasonController = TextEditingController();
  bool _showCustomReasonField = false;
  ReportService reportService = ReportService();

  final List<String> _reasons = [
    'Inaccurate information',
    'Outdated content',
    'Inappropriate content',
    'Technical issues',
    'Offensive behavior',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      title: const Text(
        "Report Course",
        style: TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
              bottom: 16.0), // Provides space at the bottom
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (String reason in _reasons)
                RadioListTile<String>(
                  value: reason,
                  groupValue: _selectedReason,
                  title: Text(reason),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedReason = value;
                      _showCustomReasonField = value == 'Other';
                    });
                  },
                ),
              if (_showCustomReasonField)
                TextField(
                  controller: _customReasonController,
                  cursorColor: AppColors.blue,
                  decoration: const InputDecoration(
                    hintText: "Specify reason",
                    hintStyle: TextStyle(
                      color: AppColors.grey,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.blue,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.blue,
                      ),
                    ),
                  ),
                  maxLines: 2,
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            "Cancel",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        TextButton(
          onPressed: _selectedReason == null
              ? null
              : () async {
                  final reportReason = _selectedReason == 'Other'
                      ? _customReasonController.text
                      : _selectedReason;

                  Navigator.pop(context);
                  if (reportReason != null) {
                    await reportCourse(reportReason);
                  }
                },
          child: const Text(
            "Report",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.deepBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        )
      ],
    );
  }

  Future<void> reportCourse(String reason) async {
    await reportService.reportCourse(
      widget.courseId,
      widget.courseTitle,
      reason,
      widget.authorId,
    );
  }
}
