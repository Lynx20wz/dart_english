import 'dart:io';

import 'package:english/ext.dart';

import 'word.dart';

class WordFile {
  final File file;
  final Word word;
  final bool organize;
  List<String> tags;
  late Map<String, String?> properties;

  WordFile(
    this.file,
    this.word, {
    this.organize = true,
    this.tags = const ['Обучение', 'Английский', 'Слова'],
    Map<String, String>? properties,
  }) {
    this.properties = properties ?? _setBaseProperties();
  }

  factory WordFile.fromFile(File file) => WordFileParser(file).fileParse();

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
    if (!file.existsSync()) {
      print('File ${file.path} does not exist. It will be created');
    }

    file.writeAsStringSync(getMd());
  }

  String getMd() {
    if (!isFull) throw Exception('File is not full');

    final buffer = StringBuffer();

    // Properties
    if (properties.isNotEmpty) {
      buffer.writeln('---');
      for (final entry in properties.entries) {
        buffer.writeln('${entry.key}: ${entry.value}');
      }
      buffer.writeln('---\n');
    }

    // Tags
    final nonEmptyTags = tags.where((tag) => tag.isNotEmpty);
    if (nonEmptyTags.isNotEmpty) {
      buffer.write('#${nonEmptyTags.join(' #')}\n\n');
    }

    // Main word
    buffer.write('`${word.mainPair.enWord}');
    if (word.transcript != null) buffer.write(' [${word.transcript}]');
    buffer.write('` - ${word.mainPair.ruWord}\n');

    // Irregular verb
    if (word.irregularVerb != null) {
      buffer.writeln(word.irregularVerb.toString());
    }

    // Extra pairs
    if (word.wordPairs.isNotEmpty) {
      for (final pair in word.wordPairs) {
        buffer.writeln('`${pair.enWord}` - ${pair.ruWord}');
      }
    }

    // Pronunciation
    if (word.hasPronunciation) {
      buffer.writeln('![[${word.mainPair.enWord}.mp3]]');
    }

    // Examples
    buffer.write(
      word.enExample != null ? '\n${word.enExample!.capitalize()}\n' : '',
    );
    buffer.write(
      word.ruExample != null ? '(${word.ruExample!.capitalize()})' : '',
    );

    return buffer.toString();
  }
}
