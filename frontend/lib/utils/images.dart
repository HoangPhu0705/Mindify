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

pickMultipleImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  List<XFile>? _file = await _imagePicker.pickMultiImage();
  if (_file != null) {
    List<List<int>> _images = [];
    for (XFile file in _file) {
      _images.add(await file.readAsBytes());
    }
    return _images;
  }

  log("No images selected");
}
