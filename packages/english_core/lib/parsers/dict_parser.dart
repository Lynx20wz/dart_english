import 'dart:io';

import 'package:english_core/classes/config.dart';
import 'package:english_core/classes/word.dart';
import 'package:english_core/classes/word_file.dart';
import 'package:path/path.dart' show extension;

class DictParser {
  final String dictPath;

  DictParser({String? dictPath}) : dictPath = dictPath ?? Config.dictionaryPath;

  List<WordFile> parseAllFiles() => Directory(dictPath)
      .listSync()
      .whereType<File>()
      .where((file) => extension(file.path) == '.md')
      .map(WordFile.fromFile)
      .toList();

  List<Word> parseAllWords() =>
      parseAllFiles().map((file) => file.word).toList();
}
