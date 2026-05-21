import 'dart:io';

import 'package:english_core/english_core.dart';
import 'package:path/path.dart' show extension;

/// Parses a dictionary directory containing word files in Markdown format.
class DictParser {
  final String dictPath;

  DictParser([String? dictPath]) : dictPath = dictPath ?? Config.dictionaryPath;

  List<WordFile> parseAllFiles() => Directory(dictPath)
      .listSync()
      .whereType<File>()
      .where((file) => extension(file.path) == '.md')
      .map(WordFile.fromFile)
      .toList();

  List<Word> parseAllWords() =>
      parseAllFiles().map((file) => file.word).toList();

  /// Formats all files which were provided.
  /// If [loadWebInfo] is `true`, web information will be loaded for each word.
  ///
  /// Yields a stream of `(index, file)` pairs for progress tracking.
  Stream<(int, WordFile)> formatAllFiles({
    List<WordFile>? files,
    bool loadWebInfo = false,
  }) async* {
    for (final (i, file) in (files ?? parseAllFiles()).indexed) {
      yield (i, file); // for progress tracking
      if (loadWebInfo) await file.word.setInfoFromWeb();
      file.write();
    }
  }
}
