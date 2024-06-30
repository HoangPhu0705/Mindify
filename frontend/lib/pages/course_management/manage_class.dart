import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ManageClass extends StatefulWidget {
  const ManageClass({super.key});

  @override
  State<ManageClass> createState() => _ManageClassState();
}

class _ManageClassState extends State<ManageClass> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          child: const Column(
            children: [],
          ),
        ),
      ),
    );
  }
}
