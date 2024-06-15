import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Display Image from URL'),
        ),
        body: Center(
          child: Image.network(
            'https://static.skillshare.com/uploads/video/thumbnails/8a6d34a8f5458236d1e4183b6c33f34e/448-252',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
