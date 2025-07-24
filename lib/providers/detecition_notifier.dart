import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/detection_history.dart';
import '../models/fuzzy_rule.dart';
import '../services/tflite_service.dart';
import 'history_notifier.dart';

class DetectionViewModel with ChangeNotifier {
  final TfliteService _tfliteService = TfliteService();
  final HistoryViewModel _historyViewModel = HistoryViewModel();
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedFile;
  String _detectionResult = '';
  String _confidenceText = '';
  bool _isLoading = false;
  bool _isFuzzyDialogOpen = false;
  bool _isChiliLeafDetected = false;
  double _mainPercentage = 0.0;

  File? get selectedFile => _selectedFile;
  String get detectionResult => _detectionResult;
  String get confidenceText => _confidenceText;
  bool get isLoading => _isLoading;
  bool get isFuzzyDialogOpen => _isFuzzyDialogOpen;
  bool get isChiliLeafDetected => _isChiliLeafDetected;
  double get mainPercentage => _mainPercentage;

  final Map<String, List<FuzzyRule>> _fuzzyRules = {
    "Kutu Daun": [
      FuzzyRule(["daun_melingkar", "daun_keriput"], 0.85),
    ],
    "Lalat Buah": [
      FuzzyRule(["bercak_buah_hitam", "buah_busuk"], 0.8),
    ],
    "Tungau": [
      FuzzyRule(["daun_melengkung", "daun_mengerut"], 0.75),
    ],
    "Thrips": [
      FuzzyRule(["daun_keriting", "daun_kuning"], 0.7),
    ],
  };

  // Symptom weights for fuzzy inference
  final Map<String, int> _symptomWeights = {
    "daun_keriting": 4,
    "daun_kuning": 3,
    "bercak_buah_hitam": 2,
    "buah_busuk": 2,
    "daun_melengkung": 3,
    "daun_mengerut": 1,
    "daun_melingkar": 3,
    "daun_keriput": 2,
  };

  Future<void> initialize() async {
    try {
      await _tfliteService.init();
    } catch (e) {
      _detectionResult = 'Gagal memuat model: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      _isLoading = true;
      notifyListeners();
      XFile? pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        _selectedFile = File(pickedFile.path);
        _detectionResult =
            'Gambar berhasil dimuat. Tekan tombol deteksi untuk menganalisis hama.';
        _confidenceText = '';
        detectPest();
      }
    } catch (e) {
      _detectionResult = 'Error memilih gambar: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> detectPest() async {
    if (_selectedFile == null) {
      _detectionResult = 'Silakan pilih gambar terlebih dahulu';
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _tfliteService.detectImage(_selectedFile!);
      _detectionResult = 'Analisa Gambar: ${result.pestName}';
      _confidenceText =
          'Keyakinan bahwa gambar tersebut ${result.pestName}: ${result.confidence.toStringAsFixed(2)}%';
      _isChiliLeafDetected = result.pestName.toLowerCase().contains(
        'daun_cabai',
      );
      notifyListeners();
    } catch (e) {
      _detectionResult = 'Error selama deteksi: ${e.toString()}';
      _confidenceText = '';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> performFuzzyDetection(List<String> symptoms) async {
    if (symptoms.isEmpty) {
      _detectionResult = 'Pilih minimal satu gejala untuk analisis fuzzy';
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final fuzzified = _fuzzification(symptoms);
      final inference = _fuzzyInference(fuzzified, symptoms);
      final results = _defuzzification(inference);
      _showResults(results);
      await saveDetectionToHistory();
    } catch (e) {
      _detectionResult = 'Error dalam fuzzy detection: ${e.toString()}';
    } finally {
      _isLoading = false;
      _isFuzzyDialogOpen = false;
      notifyListeners();
    }
  }

  Map<String, double> _fuzzification(List<String> symptoms) {
    final Map<String, double> fuzzified = {};

    for (var disease in _fuzzyRules.keys) {
      double totalFuzzyValue = 0.0;

      for (var rule in _fuzzyRules[disease]!) {
        final allMatch = rule.symptoms.every((s) => symptoms.contains(s));

        if (allMatch) {
          // Hitung membership percentage
          double membershipPercentage = rule.membershipValue * 100;
          double fuzzyValue;

          if (membershipPercentage <= 40) {
            fuzzyValue = membershipPercentage / 100.0;
          } else if (membershipPercentage <= 70) {
            fuzzyValue = ((membershipPercentage - 40) / 30.0) * 0.3 + 0.4;
          } else {
            fuzzyValue = ((membershipPercentage - 70) / 30.0) * 0.3 + 0.7;
          }

          totalFuzzyValue += fuzzyValue;
        }
      }

      fuzzified[disease] = totalFuzzyValue;
    }

    return fuzzified;
  }

  Map<String, double> _fuzzyInference(
    Map<String, double> fuzzified,
    List<String> symptoms,
  ) {
    final Map<String, double> inference = {};

    for (var disease in _fuzzyRules.keys) {
      double numeratorSum = 0.0;
      double denominatorSum = 0.0;

      for (var rule in _fuzzyRules[disease]!) {
        for (var symptom in rule.symptoms) {
          if (!symptoms.contains(symptom)) continue;

          double fuzzyValue = fuzzified[disease] ?? 0.0;
          int weight = _symptomWeights[symptom] ?? 1; // default weight = 1

          numeratorSum += fuzzyValue * weight;
          denominatorSum += fuzzyValue;
        }
      }

      double inferenceValue = denominatorSum > 0
          ? numeratorSum / denominatorSum
          : 0.0;
      inference[disease] = inferenceValue;
    }

    return inference;
  }

  Map<String, double> _defuzzification(Map<String, double> inference) {
    final Map<String, double> defuzzified = {};
    const maxWeight = 4.0;

    for (var disease in inference.keys) {
      defuzzified[disease] = inference[disease]! / maxWeight;
    }

    return defuzzified;
  }

  void _showResults(Map<String, double> results) {
    final sortedResults = results.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    _mainPercentage = sortedResults[0].value * 100;
    final mainDisease = sortedResults[0].key;
    String severity = _determineSeverity(_mainPercentage);

    _detectionResult =
        'HASIL DETEKSI: $mainDisease (${_mainPercentage.toStringAsFixed(1)}%)';
    _confidenceText =
        'Tingkat Keparahan: $severity\nRekomendasi: ${_getRecommendation(mainDisease)}';
  }

  String _determineSeverity(double confidence) {
    if (confidence >= 71) return 'Parah';
    if (confidence >= 41) return 'Sedang';
    return 'Ringan';
  }

  String _getRecommendation(String disease) {
    switch (disease) {
      case "Kutu Daun":
        return "• Semprot insektisida sistemik\n• Bersihkan gulma\n• Perbaiki drainase";
      case "Lalat Buah":
        return "• Pasang perangkap\n• Buang buah busuk\n• Gunakan plastik penutup";
      case "Thrips":
        return "• Gunakan insektisida kontak\n• Tingkatkan kelembaban\n• Rotasi tanaman";
      case "Tungau":
        return "• Semprot akarisida\n• Isolasi tanaman\n• Buang daun rusak";
      default:
        return "Konsultasikan dengan ahli pertanian";
    }
  }

  Future<void> saveDetectionToHistory() async {
    if (_selectedFile?.path == null || _detectionResult.isEmpty) return;
    try {
      String pestName = "Unknown";
      if (_detectionResult.contains('HASIL DETEKSI:')) {
        List<String> parts = _detectionResult.split('HASIL DETEKSI:');
        if (parts.length > 1) {
          pestName = parts[1].split('(')[0].trim();
        }
      }
      final severity = _determineSeverity(_mainPercentage);
      final history = DetectionHistory(
        imagePath: _selectedFile!.path,
        date: DateTime.now(),
        pestName: pestName,
        severity: severity,
        confidence: _mainPercentage,
      );
      await _historyViewModel.saveDetection(history);
    } catch (e) {
      debugPrint('Error saving to history: $e');
    }
  }

  void closeFuzzyDialog() {
    _isFuzzyDialogOpen = false;
    notifyListeners();
  }

  Future<void> deleteImage() async {
    _isChiliLeafDetected = false;
    _detectionResult = '';
    _confidenceText = '';
    _selectedFile = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _tfliteService.dispose();
    super.dispose();
  }
}
