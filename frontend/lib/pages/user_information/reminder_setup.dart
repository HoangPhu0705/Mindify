import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/services/functions/ReminderService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/utils/toasts.dart';

class ReminderSetupPage extends StatefulWidget {
  const ReminderSetupPage({super.key});

  @override
  State<ReminderSetupPage> createState() => _ReminderSetupPageState();
}

class _ReminderSetupPageState extends State<ReminderSetupPage> {
  String? _selectedDay;
  TimeOfDay? selectedTime;
  final reminderService = ReminderService();
  final dayName = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];
  int _selectedDayIndex = 0;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.input,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              dialTextColor: AppColors.deepBlue,
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: AppColors.deepBlue,
                  width: 2,
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(
                  color: AppColors.deepBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (_selectedDay == null || selectedTime == null) {
      showErrorToast(context, "Please select a day and time");
      return;
    }
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await reminderService.addReminder(
            user.uid, _selectedDay!, selectedTime!.format(context));

        showSuccessToast(context, 'Reminder saved successfully');

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save reminder: $e')),
      );
    }
  }

  String getReminderText(String reminderDay) {
    DateTime now = DateTime.now();
    int currentDayIndex = now.weekday %
        7; // Monday is 1, Sunday is 7 in Dart. We convert it to 0-6.
    int reminderDayIndex = dayName.indexOf(reminderDay);
    int difference = (reminderDayIndex - currentDayIndex) % 7;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else {
      return '$difference days left';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              AppSpacing.largeVertical,
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.close,
                  ),
                ),
              ),
              AppSpacing.mediumVertical,
              const Text(
                'When is a good time to remind you?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.mediumVertical,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 150,
                      child: ListWheelScrollView.useDelegate(
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedDayIndex = index;
                            _selectedDay = dayName[_selectedDayIndex];
                          });
                        },
                        itemExtent: 50,
                        perspective: 0.007,
                        diameterRatio: 1.2,
                        physics: const FixedExtentScrollPhysics(),
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            return Center(
                              child: Text(
                                dayName[index],
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: AppColors.deepBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          },
                          childCount: dayName.length,
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.largeHorizontal,
                  Expanded(
                    child: ListTile(
                      title: const Text('Select Time'),
                      subtitle: Text(selectedTime != null
                          ? selectedTime!.format(context)
                          : 'No time selected'),
                      trailing: const Icon(Icons.access_time),
                      onTap: () => _selectTime(context),
                    ),
                  ),
                ],
              ),
              AppSpacing.largeVertical,
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: ElevatedButton(
                  onPressed: _saveReminder,
                  style: AppStyles.primaryButtonStyle,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Looks Good!'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
