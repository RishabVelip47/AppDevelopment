import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._internal();
  DBHelper._internal();

  Database? _database;

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'calculator.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE history(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            expression TEXT,
            result TEXT
          )
        ''');
      },
    );
  }

  Future<void> saveCalculation(String expression, String result) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final List<String> history =
          prefs.getStringList('history') ?? <String>[];
      history.add(jsonEncode({'expression': expression, 'result': result}));
      await prefs.setStringList('history', history);
    } else {
      final db = await database;
      await db?.insert('history', {
        'expression': expression,
        'result': result,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final List<String> data =
          prefs.getStringList('history') ?? <String>[];
      return data
          .map((e) => jsonDecode(e) as Map<String, dynamic>)
          .toList();
    } else {
      final db = await database;
      return await db?.query('history', orderBy: 'id DESC') ?? [];
    }
  }

  Future<void> clearHistory() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('history');
    } else {
      final db = await database;
      await db?.delete('history');
    }
  }
}
