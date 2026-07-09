import 'dart:io';

import 'package:english_core/ext.dart';
import 'package:english_core/parsers/file_parser.dart';
import 'package:path/path.dart' as p;

import 'config.dart' show Config;
import 'word.dart';

class WordFile {
  final File file;
  final Word word;
  final bool organize;

  late final List<String> tags;

  /// props is an abbreviation for "properties"
  Map<String, String?> get props => organize
      ? {
          'en_word': word.mainPair.original,
          'ru_word': word.mainPair.translation,
          'transcript': word.transcript,
          'en_example': word.enExample,
          'ru_example': word.ruExample,
          'organize': 'true',
        }
      : {'organize': 'false'};

  WordFile(this.file, this.word, {this.organize = true, List<String>? tags}) {
    if (props.containsValue('')) {
      throw ArgumentError(
        'Properties cannot contain empty strings; instead, use null values.\nProps: $props',
      );
    }

    this.tags = tags ?? ['Обучение', 'Английский', 'Слова'];
  }

  factory WordFile.fromFile(File file) => FileParser(file).fileParse();

  bool get isFull => word.isFull && organize;

  void write() {
    // we can't format the file if it's not organized
    if (!organize) return;

    if (!file.existsSync()) {
      print('File ${p.basename(file.path)} does not exist. It will be created');
    }

    file.writeAsStringSync(toString());
  }

  void savePronunciation() {
    if (word.pronunciationAudio != null) {
      final audioFile = File(
        '${Config.dictionaryPath}${word.mainPair.original}.mp3',
      );
      audioFile.writeAsBytes(word.pronunciationAudio!);
    } else {
      print('No pronunciation audio to save for ${word.mainPair.original}');
    }
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
    buffer.write('` - ${word.mainPair.translation}');

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
