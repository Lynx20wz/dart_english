import 'dart:io';

import 'package:english/word.dart' show Word, WordPair;

String wordsStorage =
    r'D:\programs\Obsidian\data\Мой камень\Обучения\Английский\Слова';

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String removeSuffix(String suffix) {
    if (endsWith(suffix)) {
      return substring(0, length - suffix.length);
    }
    return this;
  }
}

void addWord(
  String enWord,
  String ruWord,
  String enExample,
  String ruExample, {
  bool overwrite = false,
}) {
  File path = File('$wordsStorage/${enWord.capitalize()}.md');

  if (path.existsSync() && !overwrite) {
    throw FileSystemException('File ${path.path} already exists');
  }

  Word word = Word(
    [WordPair(enWord, ruWord)],
    enExample: enExample.removeSuffix('.'),
    ruExample: ruExample.removeSuffix('.'),
  );

  WordFile wordFile = WordFile(path, word.setInfoFromWeb());
  wordFile.write();
}
