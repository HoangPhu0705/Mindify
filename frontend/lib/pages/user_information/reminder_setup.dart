import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/services/functions/ReminderService.dart';

class ReminderSetupPage extends StatefulWidget {
  const ReminderSetupPage({super.key});

  @override
  State<ReminderSetupPage> createState() => _ReminderSetupPageState();
}

class _ReminderSetupPageState extends State<ReminderSetupPage> {
  String? _selectedDay;
  TimeOfDay? selectedTime;
  final reminderService = ReminderService();
  final dayName = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (_selectedDay == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a day and time')),
      );
      return;
    }
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await reminderService.addReminder(user.uid, _selectedDay!, selectedTime!.format(context));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder saved successfully')),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save reminder: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up Learning Reminder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Select a Day'),
            ListView.builder(
              shrinkWrap: true,
              itemCount: dayName.length,
              itemBuilder: (context, index) {
                return RadioListTile<String>(
                  title: Text(dayName[index]),
                  value: dayName[index],
                  groupValue: _selectedDay,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedDay = value;
                    });
                  },
                );
              }
            ),
            
            SizedBox(height: 20),
            ListTile(
              title: const Text('Select Time'),
              subtitle: Text(selectedTime != null
                  ? selectedTime!.format(context)
                  : 'No time selected'),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectTime(context),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveReminder,
              child: const Text('Save Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
