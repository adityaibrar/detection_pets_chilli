import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageNotifier with ChangeNotifier {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;
  XFile? get selectedImage => _selectedImage;

  Future<void> selectImage(ImageSource source) async {
    final XFile? image = await _imagePicker.pickImage(source: source);
    if (image != null) {
      _selectedImage = image;
    }
    notifyListeners();
  }

  Future<void> deleteImage() async {
    _selectedImage = null;
    notifyListeners();
  }
}
