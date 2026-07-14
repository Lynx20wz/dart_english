import 'dart:io' show File, Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    show sqfliteFfiInit, databaseFactoryFfi;

Future<Database> createDatabase() async {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  final dir = await getApplicationDocumentsDirectory();
  final path = p.join(dir.path, 'english_helper.db');
  var file = File(path);
  if (!file.existsSync()) file.createSync(recursive: true);

  print('Database path: $path');

  return await openDatabase(
    path,
    version: 1,
    onCreate: (db, _) async {
      await db.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        original TEXT UNIQUE,
        transcription TEXT,
        original_example TEXT,
        translation_example TEXT,
        part_of_speech TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
      await db.execute('''
      CREATE TABLE translations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id INTEGER REFERENCES words(id),
        translation TEXT
      )
    ''');
    },
  );
}
