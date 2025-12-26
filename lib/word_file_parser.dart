import 'dart:io';

import 'package:path/path.dart' as p;

import 'word.dart';
import 'word_fille.dart';

class WordFileParser {
  final File file;
  late final String content = file.existsSync() ? file.readAsStringSync() : '';

  WordFileParser(this.file);

  /// Parse a word file.

  /// Example:
  ///     ---
  ///     en_word: avoid {герундий}
  ///     ru_word: избегать
  ///     level: B1
  ///     transcript: ə'vɔɪd
  ///     en_example: I avoid meeting him
  ///     ru_example: Я избегаю встречи с ним
  ///     organize: true
  ///     ---

  ///     #Обучение #Английский #Слова #B1

  ///     `avoid {герундий} [ə'vɔɪd]` - избегать

  ///     ![[avoid {герундий}.mp3]]

  ///     I avoid meeting him
  ///     (Я избегаю встречи с ним)

  ///     ->
  ///         properties = {
  ///             'en_word': 'avoid {герундий}',
  ///             'ru_word': 'избегать',
  ///             'level': 'B1',
  ///             'transcript': 'ə'vɔɪd',
  ///             'en_example': 'I avoid meeting him',
  ///             'ru_example': 'Я избегаю встречи с ним',
  ///             'organize': 'true',
  ///         }
  ///         tags = ['#Обучение', '#Английский', '#Слова', '#B1']
  ///         word = {
  ///             'pairs': ['avoid', 'избегать'],
  ///             'level': 'B1',
  ///             'transcript': 'ə'vɔɪd',
  ///             'en_example': 'I avoid meeting him',
  ///             'ru_example': 'Я избегаю встречи с ним',
  ///         }
  WordFile fileParse() {
    final properties = _getProperties();
    final organize = properties['organize'] == 'true';

    if (!organize) {
      return WordFile(
        file,
        Word([WordPair(p.basenameWithoutExtension(file.path), '')]),
        properties: properties,
        organize: false,
      );
    }

    final List<String> tags = [
      ...RegExp(
        r'^#(\p{L}+)(?: #(\p{L}+))*',
      ).allMatches(content).map((match) => match.group(1)!),
    ];
    final (enExample, ruExample) = _getExample();
    final hasPronunciation = _hasPronunciation();

    final word = Word(
      _getWordPairs(),
      enExample: enExample,
      ruExample: ruExample,
      irregularVerb: _getIrregularVerb(),
      hasPronunciation: hasPronunciation,
      transcript: _getTranscript(),
      level: tags[-1] != 'Слова' ? tags[-1] : '',
    );

    return WordFile(file, word, properties: properties, tags: tags);
  }

  /// Returns properties from file.

  /// Example:
  ///     ---
  ///     key1: value
  ///     key2: value
  ///     ---
  ///     -> {'key1': 'value', 'key2': 'value'}
  Map<String, String> _getProperties() {
    final lines = _splitContentByLines(content);
    final lastPropertyLineIndex = lines.lastIndexOf('---');
    if (lastPropertyLineIndex == -1) return {};

    return Map.fromEntries(
      RegExp(r'^(\S+):\s*(\S+)$')
          .allMatches(lines.sublist(1, lastPropertyLineIndex + 1).join('\n'))
          .map(
            (match) => MapEntry(match.group(1)!, _removeLinks(match.group(2)!)),
          ),
    );
  }

  /// Returns word pairs from file.

  /// Example:
  ///     `avoid {герундий} [ə'vɔɪd]` - избегать
  ///     -> ['WordPair: avoid {герундий} - избегать']
  List<WordPair> _getWordPairs() =>
      RegExp(
            r'^`(.*?)(?: \[.*])?`(?:.*)?[-—] (?:\[\[)?(?:.*\|)?(.*[^]\n]?)(?:]])?',
            multiLine: true,
          )
          .allMatches(content)
          .map((match) => WordPair(match.group(1)!, match.group(2)!))
          .toList();

  /// Returns transcript from file.

  /// Example:
  ///     `avoid {герундий} [ə'vɔɪd]` - избегать
  ///     -> 'ə'vɔɪd'
  String? _getTranscript() =>
      RegExp(r'^`.*?(?: \[(.*)])?`').firstMatch(content)?.group(1);

  /// Returns irregular verb from file.

  /// Example:
  ///     wear - wore - worn
  ///     -> IrregularVerb: wear - wore - worn

  /// If word is not an irregular verb, returns None
  IrregularVerb? _getIrregularVerb() {
    final result = RegExp(r'(.*) - (.*) - (.*)').firstMatch(content);
    return result == null
        ? null
        : IrregularVerb(result[1]!, result[2]!, result[3]!);
  }

  /// Returns the lines that contain examples.

  /// Example:
  ///     I avoid meeting him
  ///     (Я избегаю встречи с ним)
  ///     -> ('I avoid meeting him', 'Я избегаю встречи с ним')

  /// If examples are not found, returns ('', '')
  (String, String) _getExample() {
    final lines = _splitContentByLines(content);

    final ruMatch = RegExp(r'^\((.+)\)$').firstMatch(content);
    if (ruMatch == null) return ('', '');

    final ruExample = ruMatch.group(1)!;

    final ruLineIndex = lines.indexWhere((line) => line == '($ruExample)');
    return (lines[ruLineIndex - 1], ruExample);
  }

  /// Checks if file has pronunciation.

  /// Example:
  ///     ![[audio.mp3]] (contains in file)
  ///     -> True
  bool _hasPronunciation() => RegExp(r'!\[\[.+?\.mp3]]').hasMatch(content);

  /// Removes links from string.

  /// Example:
  ///     [[Статья]]
  ///     -> Статья

  ///     [[Статья|интересная статья]]
  ///     -> интересная статья
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
