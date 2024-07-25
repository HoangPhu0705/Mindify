import 'package:flutter/material.dart';

class SubmitProjectPage extends StatefulWidget {
  const SubmitProjectPage({super.key});

  @override
  State<SubmitProjectPage> createState() => _SubmitProjectPageState();
}

class _SubmitProjectPageState extends State<SubmitProjectPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Project'),
      ),
      body: const Center(
        child: Text('Submit Project Page'),
      ),
    );
  }
}
