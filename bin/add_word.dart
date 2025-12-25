import 'dart:io';

import 'package:english/ext.dart';
import 'package:english/word.dart';
import 'package:english/word_fille.dart';

String wordsStorage =
    r'D:\programs\Obsidian\data\Мой камень\Обучения\Английский\Слова';

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
