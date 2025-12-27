import 'dart:io';

import 'package:args/args.dart';
import 'package:english/ext.dart';
import 'package:english/word.dart';
import 'package:english/word_file.dart';
import 'package:path/path.dart' as p;

final wordsStorage =
    r'D:/programs/Obsidian/data/Мой камень/Обучения/Английский/Слова'; // TODO move to config

void main(List<String> args) async {
  try {
    if (args.isEmpty || args.contains('--repl')) {
      await _replMode();
    } else {
      await _cliMode(args);
    }
    print('\x1b[32m✓ Done\x1b[0m');
  } catch (e) {
    print('\x1b[31m✗ $e\x1b[0m');
    exit(1);
  }
}

Future<void> _cliMode(List<String> args) async {
  final parser = ArgParser()
    ..addFlag('overwrite', abbr: 'o', help: 'Overwrite if exists')
    ..addFlag('repl', abbr: 'r', help: 'Interactive mode');

  final parsed = parser.parse(args);
  final positional = parsed.rest;

  if (positional.length < 2) {
    throw ArgumentError(
      'Usage: <en_word> <ru_word> [en_example] [ru_example] [--overwrite]',
    );
  }

  await addWord(
    enWord: positional[0].capitalize(),
    ruWord: positional[1].capitalize(),
    enExample: positional.getOrNull(2)?.capitalize(),
    ruExample: positional.getOrNull(3)?.capitalize(),
    overwrite: parsed['overwrite'] as bool,
  );
}

Future<void> _replMode() async {
  final enWord = _prompt('English word', required: true);
  final ruWord = _prompt('Russian translation', required: true);
  final enExample = _prompt('English example (optional)');

  final ruExample = enExample.isNotEmpty
      ? _prompt('Russian example (optional)')
      : null;

  final overwrite = _confirm('Overwrite if exists?');

  await addWord(
    enWord: enWord,
    ruWord: ruWord,
    enExample: enExample,
    ruExample: ruExample,
    overwrite: overwrite,
  );
}

String _prompt(String message, {bool required = false}) {
  while (true) {
    print('$message: ');
    final input = stdin.readLineSync()?.trim() ?? '';

    if (required && input.isEmpty) {
      print('\x1b[33mRequired field!\x1b[0m');
      continue;
    }

    return input.capitalize();
  }
}

bool _confirm(String message, {bool default_ = false}) {
  print('$message ${default_ ? '(Y/n)' : '(y/N)'}: ');
  final input = stdin.readLineSync()?.trim().toLowerCase();

  return input == 'y' || (input!.isEmpty && default_);
}

Future<void> addWord({
  required String enWord,
  required String ruWord,
  String? enExample,
  String? ruExample,
  bool overwrite = false,
}) async {
  final path = File('$wordsStorage/$enWord.md');

  if (path.existsSync() && !overwrite) {
    throw FileSystemException('File ${p.basename(path.path)} already exists');
  }

  final word = Word(
    [WordPair(enWord, ruWord)],
    enExample: enExample?.removeSuffix('.'),
    ruExample: ruExample?.removeSuffix('.'),
  );

  await word.setInfoFromWeb();
  WordFile(path, word).write();
}
