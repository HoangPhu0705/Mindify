import "dart:developer";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";

pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _file = await _imagePicker.pickImage(source: source);
  if (_file != null) {
    return await _file.readAsBytes();
  }

  log("No image selected");
}

Future<List<XFile>?> pickMultipleImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  return await _imagePicker.pickMultiImage();
}
