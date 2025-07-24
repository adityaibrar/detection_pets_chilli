import 'dart:io';
import 'dart:typed_data';
import '../constant/utils/file_util.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

import '../models/pest_detection.dart';

class TfliteService {
  static const int inputSize = 224;
  static const int pixelSize = 3;
  static const int imageMean = 128;
  static const double imageStd = 128.0;

  late Interpreter _interpreter;
  late List<String> _labels;

  Future<void> init() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/leaf_model.tflite',
      );
      _labels = await FileUtil.loadLabels('assets/labels/coco_labels.txt');
    } catch (e) {
      throw Exception('Failed to load model: $e');
    }
  }

  Future<PestDetection> detectImage(File image) async {
    final imageBytes = await image.readAsBytes();
    final decodedImage = img.decodeImage(imageBytes);

    if (decodedImage == null) {
      throw Exception('Failed to decode image');
    }

    final resizedImage = img.copyResize(
      decodedImage,
      width: inputSize,
      height: inputSize,
    );
    final inputBuffer = _convertImageToByteBuffer(resizedImage);

    final output = List.filled(
      1 * _labels.length,
      0.0,
    ).reshape([1, _labels.length]);
    _interpreter.run(inputBuffer, output);

    int maxIndex = 0;
    double maxConfidence = output[0][0];
    for (int i = 1; i < output[0].length; i++) {
      if (output[0][i] > maxConfidence) {
        maxConfidence = output[0][i];
        maxIndex = i;
      }
    }

    return PestDetection(
      pestName: _labels[maxIndex],
      confidence: maxConfidence * 100,
      imagePath: image.path,
    );
  }

  ByteBuffer _convertImageToByteBuffer(img.Image image) {
    var inputBuffer = ByteData(
      inputSize * inputSize * 3 * 4,
    ); // 3 channels (RGB), 4 bytes per float

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final r = image.getPixel(x, y).r;
        final g = image.getPixel(x, y).g;
        final b = image.getPixel(x, y).b;

        final int offset = (y * inputSize + x) * 4 * 3;

        inputBuffer.setFloat32(
          offset,
          (r - TfliteService.imageMean) / TfliteService.imageStd,
          Endian.little,
        );
        inputBuffer.setFloat32(
          offset + 4,
          (g - TfliteService.imageMean) / TfliteService.imageStd,
          Endian.little,
        );
        inputBuffer.setFloat32(
          offset + 8,
          (b - TfliteService.imageMean) / TfliteService.imageStd,
          Endian.little,
        );
      }
    }

    return inputBuffer.buffer;
  }

  void dispose() {
    _interpreter.close();
  }
}
