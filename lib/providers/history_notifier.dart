import 'package:flutter/material.dart';

import '../models/detection_history.dart';
import '../services/database_service.dart';

class HistoryViewModel with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<DetectionHistory> _historyList = [];
  bool _isLoading = false;

  List<DetectionHistory> get historyList => _historyList;
  bool get isLoading => _isLoading;

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      _historyList = await _databaseService.getAllHistory();
    } catch (e) {
      _historyList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveDetection(DetectionHistory history) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _databaseService.insertDetection(history);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDetection(int id) async {
    await _databaseService.deleteDetection(id);
    await loadHistory();
  }
}
