import 'dart:io';
import 'dart:typed_data' show Uint8List;

import 'package:english_core/classes/classes.dart';
import 'package:path/path.dart' as p;

class FileParser {
  final File file;
  late final String _content = file.existsSync() ? file.readAsStringSync() : '';

  FileParser(this.file);

  WordFile fileParse() {
    final props = _getProps();

    final organize = props['organize'] == 'true';

    if (!organize) {
      return WordFile(
        file,
        Word(WordPair(p.basenameWithoutExtension(file.path))),
        organize: false,
      );
    }

    final List<String> tags = _getTags();
    final (enExample, ruExample) = _getExamples();
    final [rawMainPair, ...extra] = _getWordPairs();
    final (translation, note) = _separateTranslationAndNote(
      rawMainPair.translation,
    );
    final mainPair = rawMainPair.copyWith(translation: translation);

    final word = Word(
      mainPair,
      extraPairs: extra.isNotEmpty ? extra : null,
      originalExample: enExample,
      note: note,
      translationExample: ruExample,
      irregularVerb: _getIrregularVerb(),
      pronunciationAudio: _getPronunciationAudio(),
      transcription: _getTranscript(),
      partOfSpeech:
          props['part_of_speech'] != null && props['part_of_speech'] != 'null'
          ? PartOfSpeech.values.byName(props['part_of_speech']!)
          : null,
    );

    return WordFile(file, word, tags: tags);
  }

  // Regex check: https://regex101.com/r/o6TpPs
  Map<String, dynamic> _getProps() => Map.fromEntries(
    RegExp(r'^(\S+):\s*(.*)$', multiLine: true)
        .allMatches(_content)
        .map((match) => MapEntry(match.group(1)!, match.group(2)!))
        .toList(),
  );

  // Regex check: https://regex101.com/r/3ibZA1
  List<WordPair> _getWordPairs() =>
      RegExp(
            r'^`(.*?)(?: \[.*])?`(?:.*)?[-—] (?:\[\[)?(?:.*\|)?([^\]\n]*)(?:]])?',
            multiLine: true,
          )
          .allMatches(_content)
          .map((match) => WordPair(match.group(1)!, match.group(2)!))
          .toList();

  /// Returns the transcript of the word.
  ///
  /// Example:
  /// '`acquisition [ˌæk.wɪˈzɪʃ.ən]`' -> 'ˌæk.wɪˈzɪʃ.ən'
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

  /// Returns the example on original and translated languages.
  ///
  /// Example:
  /// ```md
  /// It was a great acquisition
  /// (Это было отличное приобретение)
  /// ```
  /// -> 'It was a great acquisition', 'Это было отличное приобретение'
  (String?, String?) _getExamples() {
    final lines = _splitContentByLines(_content);

    final ruMatch = RegExp(r'^\((.+)\)$', multiLine: true).firstMatch(_content);
    if (ruMatch == null) return (null, null);

    final ruExample = ruMatch.group(1)!;

    final ruLineIndex = lines.indexWhere((line) => line == '($ruExample)');
    return (lines[ruLineIndex - 1], ruExample);
  }

  Uint8List? _getPronunciationAudio() {
    final word = p.basenameWithoutExtension(file.path).toLowerCase();
    final audioFile = File('$audioFolder$word.mp3');
    print(audioFile.path);

    return audioFile.existsSync() ? audioFile.readAsBytesSync() : null;
  }

  /// Splits the content by lines, removing empty lines and trimming whitespace.
  List<String> _splitContentByLines(String content) => content
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  /// Separates the translation from the note.
  ///
  /// Example: 'book (как существильное)' -> 'book', 'как существильное'
  (String?, String?) _separateTranslationAndNote(String? translationWithNote) {
    if (translationWithNote == null) return (null, null);
    final res = RegExp(r'(.*) \((.*)\)').firstMatch(translationWithNote);
    return res != null
        ? (res.group(1), res.group(2))
        : (translationWithNote, null);
  }
}
