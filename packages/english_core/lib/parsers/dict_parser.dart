import 'dart:io';

import 'package:english_core/english_core.dart';
import 'package:path/path.dart' show extension;

/// Parses a dictionary directory containing word files in Markdown format.
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
