import 'dart:io';

import 'package:args/args.dart';
import 'package:english/ext.dart';
import 'package:english/word.dart';
import 'package:english/word_fille.dart';
import 'package:path/path.dart' as p;

String wordsStorage =
    r'D:/programs/Obsidian/data/Мой камень/Обучения/Английский/Слова';

void addWord(
  String enWord,
  String ruWord,
  String enExample,
  String ruExample, {
  bool overwrite = false,
}) async {
  File path = File('$wordsStorage/${enWord.capitalize()}.md');

  if (path.existsSync() && !overwrite) {
    throw FileSystemException('File ${p.basename(path.path)} already exists');
  }

  Word word = Word(
    [WordPair(enWord, ruWord)],
    enExample: enExample.removeSuffix('.'),
    ruExample: ruExample.removeSuffix('.'),
  );
  await word.setInfoFromWeb();

  WordFile wordFile = WordFile(path, word);
  wordFile.write();
}

void main(List<String> arguments) {
  try {
    final parser = ArgParser();
    parser.addFlag('overwrite', abbr: 'o', defaultsTo: false);

    final args = parser.parse(arguments);
    final positionalArgs = args.rest;

    if (positionalArgs.length < 2) {
      print('Error: Need at least English and Russian words');
      print('Usage: dart run english <en> <ru> [en_ex] [ru_ex] [--overwrite]');
      exit(1);
    }

    addWord(
      positionalArgs[0],
      positionalArgs[1],
      positionalArgs.length > 2 ? positionalArgs[2] : '',
      positionalArgs.length > 3 ? positionalArgs[3] : '',
      overwrite: args['overwrite'] as bool,
    );
  } catch (e) {
    print('\x1b[31mError: $e\x1b[0m');
    exit(1);
  }
}
