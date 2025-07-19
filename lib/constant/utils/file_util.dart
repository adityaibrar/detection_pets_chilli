import 'package:flutter/services.dart' show rootBundle;

class FileUtil {
  static Future<List<String>> loadLabels(String path) async {
    final content = await rootBundle.loadString(path);
    return content.split('\n');
  }
}