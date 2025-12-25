import 'dart:io';

import 'word.dart';

class WordFile {
  final File path;
  final Word word;
  final bool organize;
  List<String> tags;
  late Map<String, String?> properties;

  WordFile(
    this.path,
    this.word, {
    this.organize = true,
    List<String>? tags,
    Map<String, String>? properties,
  }) : tags = tags ?? ['Обучение', 'Английский', 'Слова'] {
    this.properties = properties ?? _setBaseProperties();
  }

  Map<String, String?> _setBaseProperties() => {
    'en_word': word.mainPair.enWord,
    'ru_word': word.mainPair.ruWord,
    'level': word.level,
    'en_example': word.enExample,
    'ru_example': word.ruExample,
    'transcript': word.transcript,
    'organize': 'true',
  };

  @override
  String toString() => getMd();

  bool get isFull => word.isFull && organize;

  void write() {
    if (!word.)
  }
}
