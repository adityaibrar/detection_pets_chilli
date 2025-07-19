import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/detection_history.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('detection_pest_chilli.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE detection_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        imagePath TEXT NOT NULL,
        date TEXT NOT NULL,
        pestName TEXT NOT NULL,
        severity TEXT NOT NULL,
        confidence REAL NOT NULL
      )
    ''');
  }

  Future<int> insertDetection(DetectionHistory history) async {
    final db = await instance.database;
    debugPrint('aku kena hit');
    return await db.insert('detection_history', history.toMap());
  }

  Future<List<DetectionHistory>> getAllHistory() async {
    final db = await instance.database;
    final maps = await db.query('detection_history', orderBy: 'date DESC');

    return maps.map((map) => DetectionHistory.fromMap(map)).toList();
  }

  Future<int> deleteDetection(int id) async {
    final db = await instance.database;
    return await db.delete(
      'detection_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
