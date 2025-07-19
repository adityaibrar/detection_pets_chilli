class PestDetection {
  final String pestName;
  final double confidence;
  final String? imagePath;

  PestDetection({
    required this.pestName,
    required this.confidence,
    this.imagePath,
  });
}