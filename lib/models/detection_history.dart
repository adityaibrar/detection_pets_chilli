class DetectionHistory {
  final int? id;
  final String imagePath;
  final DateTime date;
  final String pestName;
  final String severity;
  final double confidence;

  DetectionHistory({
    this.id,
    required this.imagePath,
    required this.date,
    required this.pestName,
    required this.severity,
    required this.confidence,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'date': date.toIso8601String(),
      'pestName': pestName,
      'severity': severity,
      'confidence': confidence,
    };
  }

  factory DetectionHistory.fromMap(Map<String, dynamic> map) {
    return DetectionHistory(
      id: map['id'],
      imagePath: map['imagePath'],
      date: DateTime.parse(map['date']),
      pestName: map['pestName'],
      severity: map['severity'],
      confidence: map['confidence'],
    );
  }
}