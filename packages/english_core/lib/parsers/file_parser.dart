import 'dart:io';

import 'package:english_core/classes/classes.dart';
import 'package:english_core/ext.dart';
import 'package:path/path.dart' as p;

class FileParser {
  final File file;
  late final String _content = file.existsSync() ? file.readAsStringSync() : '';

  FileParser(this.file);

  WordFile fileParse() {
    final properties = _getProperties();
    final organize = properties['organize'] == 'true';

    if (!organize) {
      return WordFile(
        file,
        Word(WordPair(p.basenameWithoutExtension(file.path))),
        properties: properties,
        organize: false,
      );
    }

    final List<String> tags = _getTags();
    final (enExample, ruExample) = _getExample();
    final [mainPair, ...extra] = _getWordPairs();

    final word = Word(
      mainPair,
      extraPairs: extra,
      enExample: enExample,
      ruExample: ruExample,
      irregularVerb: _getIrregularVerb(),
      pronunciationAudio: _getPronunciationAudio(),
      transcript: _getTranscript(),
      level: tags.last != 'Слова' ? tags.last : '',
    );

    return WordFile(file, word, properties: properties, tags: tags);
  }

  Map<String, String?> _getProperties() {
    final lines = _splitContentByLines(_content);
    final lastPropertyLineIndex = lines.lastIndexOf('---');
    if (lastPropertyLineIndex == -1) return {};

    return Map.fromEntries(
      RegExp(r'^(\S+):\s*(.+)$', multiLine: true)
          .allMatches(lines.sublist(1, lastPropertyLineIndex).join('\n'))
          .map(
            (match) => MapEntry(
              match.group(1)!,
              _removeLinks(match.group(2)!).nullIfEmpty,
            ),
          ),
    );
  }

  List<WordPair> _getWordPairs() =>
      RegExp(
            r'^`(.*?)(?: \[.*])?`(?:.*)?[-—] (?:\[\[)?(?:.*\|)?(.*[^]\n]?)(?:]])?',
            multiLine: true,
          )
          .allMatches(_content)
          .map((match) => WordPair(match.group(1)!, match.group(2)!.trim()))
          .toList();

  String? _getTranscript() => RegExp(
    r'^`.*?(?: \[(.*)])?`',
    multiLine: true,
  ).firstMatch(_content)?.group(1);

  List<String> _getTags() => [
    ...RegExp(
      r'(?<=#)\S+',
    ).allMatches(_content).map((match) => match.group(0)!),
  ];

  IrregularVerb? _getIrregularVerb() {
    final result = RegExp(r'(.*) - (.*) - (.*)').firstMatch(_content);
    return result == null
        ? null
        : IrregularVerb(result[1]!, result[2]!, result[3]!);
  }

  (String, String) _getExample() {
    final lines = _splitContentByLines(_content);

    final ruMatch = RegExp(r'^\((.+)\)$').firstMatch(_content);
    if (ruMatch == null) return ('', '');

    final ruExample = ruMatch.group(1)!;

    final ruLineIndex = lines.indexWhere((line) => line == '($ruExample)');
    return (lines[ruLineIndex - 1], ruExample);
  }

  List<int> _getPronunciationAudio() {
    final captures = RegExp(r'!\[\[(.+?)\.mp3]]').allMatches(_content).toList();
    if (captures.isEmpty) return [];

    final audioFile = File(
      'D:/Programs/Obsidian/data/Мой камень/Кэш/слова/${captures.first.group(1)}.mp3',
    );

    return audioFile.existsSync() ? audioFile.readAsBytesSync() : [];
  }

  String _removeLinks(String line) => line.replaceAllMapped(
    RegExp(r'\[\[(?:.*\|)?(.*?)]]'),
    (Match m) => m.group(1) ?? '',
  );

  List<String> _splitContentByLines(String content) => content
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
}
