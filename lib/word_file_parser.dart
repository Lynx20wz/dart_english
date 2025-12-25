import 'dart:io';

import 'word.dart';

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
  void fileParse() {}

  /// Returns properties from file.

  /// Example:
  ///     ---
  ///     key1: value
  ///     key2: value
  ///     ---
  ///     -> {'key1': 'value', 'key2': 'value'}
  Map<String, String> _getProperties() => {};

  /// Returns word pairs from file.

  /// Example:
  ///     `avoid {герундий} [ə'vɔɪd]` - избегать
  ///     -> ['WordPair: avoid {герундий} - избегать']
  List<WordPair> _getWordPairs() => [];

  /// Returns transcript from file.

  /// Example:
  ///     `avoid {герундий} [ə'vɔɪd]` - избегать
  ///     -> 'ə'vɔɪd'
  String _getTranscript() => '';

  /// Returns irregular verb from file.

  /// Example:
  ///     wear - wore - worn
  ///     -> IrregularVerb: wear - wore - worn

  /// If word is not an irregular verb, returns None
  IrregularVerb? _getIrregularVerb() => null;

  /// Returns the lines that contain examples.

  /// Example:
  ///     I avoid meeting him
  ///     (Я избегаю встречи с ним)
  ///     -> ('I avoid meeting him', 'Я избегаю встречи с ним')

  /// If examples are not found, returns ('', '')
  (String, String) _getExample() => ('', '');

  /// Checks if file has pronunciation.

  /// Example:
  ///     ![[audio.mp3]] (contains in file)
  ///     -> True
  bool _hasPronunciation() => false;

  /// Removes links from string.

  /// Example:
  ///     [[Статья]]
  ///     -> Статья

  ///     [[Статья|интересная статья]]
  ///     -> интересная статья
  String _removeLinks(String line) => '';
}
