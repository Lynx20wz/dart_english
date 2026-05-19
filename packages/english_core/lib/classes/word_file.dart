import 'dart:io';

import 'package:english_core/ext.dart';
import 'package:english_core/parsers/file_parser.dart';
import 'package:path/path.dart' as p;

import 'word.dart';

class WordFile {
  final File file;
  final Word word;
  final bool organize;

  /// props is an abbreviation for "properties"
  late Map<String, String?> props;
  late final List<String> tags;

  WordFile(
    this.file,
    this.word, {
    this.organize = true,
    List<String>? tags,
    Map<String, String?>? props,
  }) {
    final baseProps = {
      'en_word': word.mainPair.original,
      'ru_word': word.mainPair.translate,
      'level': word.level,
      'transcript': word.transcript,
      'en_example': word.enExample,
      'ru_example': word.ruExample,
      'organize': 'true',
    };

    this.props = {
      ...baseProps,
      for (final e in (props ?? {}).entries) e.key: e.value ?? baseProps[e.key],
    };

    if (this.props.containsValue('')) {
      throw ArgumentError(
        'Properties cannot contain empty strings; instead, use null values.\nProps: ${this.props}',
      );
    }

    // My standart tags
    this.tags = tags ?? ['Обучение', 'Английский', 'Слова'];

    // Add level tag if available
    if (word.level != null) this.tags.add(word.level!);
  }

  factory WordFile.fromFile(File file) => FileParser(file).fileParse();

  bool get isFull => word.isFull && organize;

  void write() {
    if (!file.existsSync()) {
      print('File ${p.basename(file.path)} does not exist. It will be created');
    }

    file.writeAsStringSync(toString());
  }

  /// Returns a string representation of the word file.
  ///
  /// The string is formatted according to the markdown specification.
  /// IMPORTANT: There must be an empty line at the end of the file
  @override
  String toString() {
    final buffer = StringBuffer();

    // Properties
    if (props.isNotEmpty) {
      buffer.writeln('---');
      for (final entry in props.entries) {
        buffer.writeln('${entry.key}: ${entry.value}');
      }

      buffer.writeln('---');
    }

    // Tags
    if (tags.isNotEmpty) {
      buffer.writeln('\n#${tags.join(' #')}');
    }

    // Main word
    buffer.write('\n`${word.mainPair.original}');
    if (word.transcript != null) buffer.write(' [${word.transcript}]');
    buffer.write('` - ${word.mainPair.translate}');

    // Extra pairs
    for (final pair in word.extraPairs ?? []) {
      buffer.write('\n`${pair.original}` - ${pair.translate}');
    }

    // Irregular verb
    if (word.irregularVerb != null) {
      buffer.write('\n\n${word.irregularVerb}');
    }

    // Pronunciation
    if (word.pronunciationAudio != null) {
      buffer.write('\n\n![[${word.mainPair.original}.mp3]]');
    }

    // Examples
    buffer.write(
      word.enExample != null ? '\n\n${word.enExample!.capitalize()}\n' : '',
    );
    buffer.write(
      word.ruExample != null ? '(${word.ruExample!.capitalize()})' : '',
    );

    buffer.writeln();
    return buffer.toString();
  }
}
