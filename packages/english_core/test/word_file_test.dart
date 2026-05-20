import 'dart:io';

import 'package:english_core/english_core.dart';
import 'package:test/test.dart';

final testFile = File('test.md');

Word buildFullWord() => Word(
  WordPair('come', 'приходить'),
  extraPairs: [
    WordPair('incoming', 'входящий'),
    WordPair('upcoming', 'предстоящий'),
  ],
  level: 'A1',
  transcript: 'kʌm',
  enExample: 'I came too early',
  ruExample: 'Я пришёл слишком рано',
  pronunciationAudio: [0, 0, 0],
  irregularVerb: const IrregularVerb('come', 'came', 'come'),
);

String buildExpected(WordFile wordFile) {
  // deconstruction
  final WordFile(
    word: Word(
      :level,
      :transcript,
      :enExample,
      :ruExample,
      :pronunciationAudio,
      :irregularVerb,
      mainPair: WordPair(:original, :translate),
      extraPairs: extraWordPairs,
    ),
    :tags,
    :organize,
  ) = wordFile;
  final mainLine =
      '`$original${transcript != null ? " [$transcript]" : ""}`${translate != null ? " - $translate" : ""}';
  final extraPairsLine = extraWordPairs?.isNotEmpty ?? false
      ? '\n${extraWordPairs!.map((pair) => '`${pair.original}` - ${pair.translate}').join('\n')}'
      : '';
  final irregularLine = irregularVerb != null
      ? '\n\n`${irregularVerb.firstForm}` - `${irregularVerb.secondForm}` - `${irregularVerb.thirdForm}`'
      : '';
  final pronunciationAudioLine = pronunciationAudio != null
      ? '\n\n![[$original.mp3]]'
      : '';
  final examplesLine = enExample != null ? '\n\n$enExample\n($ruExample)' : '';

  return '''---
en_word: $original
ru_word: $translate
level: $level
transcript: $transcript
en_example: $enExample
ru_example: $ruExample
organize: true
---

#${tags.join(' #')}

$mainLine$extraPairsLine$irregularLine$pronunciationAudioLine$examplesLine
''';
}

void main() {
  group('toString()', () {
    test('only main pair', () {
      final wordFile = WordFile(testFile, Word(WordPair('test', 'тест')));
      expect(wordFile.toString(), buildExpected(wordFile));
    });

    test('multiple pairs', () {
      final wordFile = WordFile(
        testFile,
        Word(
          WordPair('able', 'в состоянии'),
          extraPairs: [WordPair('able', 'умеющий')],
        ),
      );

      expect(wordFile.toString(), buildExpected(wordFile));
    });

    test('with transcript', () {
      final wordFile = WordFile(
        testFile,
        Word(WordPair('test', 'тест'), transcript: 'test'),
      );
      expect(wordFile.toString(), buildExpected(wordFile));
    });

    test('with examples', () {
      final wordFile = WordFile(
        testFile,
        Word(
          WordPair('test', 'тест'),
          enExample: 'I wrote some tests',
          ruExample: 'Я написал несколько тестов',
        ),
      );
      expect(wordFile.toString(), buildExpected(wordFile));
    });

    test('with level', () {
      final wordFile = WordFile(
        testFile,
        Word(WordPair('test', 'тест'), level: 'A2'),
      );
      expect(wordFile.toString(), buildExpected(wordFile));
    });

    test('with pronunciation audio', () {
      final wordFile = WordFile(
        testFile,
        Word(WordPair('test', 'тест'), pronunciationAudio: [0, 0, 0]),
      );

      expect(wordFile.toString(), buildExpected(wordFile));
    });

    test('with irregular verb', () {
      final wordFile = WordFile(
        testFile,
        Word(
          WordPair('come', 'приходить'),
          irregularVerb: const IrregularVerb('come', 'came', 'come'),
        ),
      );

      expect(wordFile.toString(), buildExpected(wordFile));
    });

    test('full', () {
      final wordFile = WordFile(testFile, buildFullWord());

      expect(wordFile.toString(), buildExpected(wordFile));
    });
  });

  test('Write func (with full WordFile)', () {
    final wordFile = WordFile(testFile, buildFullWord());

    wordFile.write();

    expect(testFile.readAsStringSync(), buildExpected(wordFile));
  });

  group('Props', () {
    test('setup', () {
      final wordFile = WordFile(
        testFile,
        Word(WordPair('test', 'тест')),
        props: {'level': 'B2', 'transcript': null},
        organize: true,
      );

      expect(
        wordFile.props,
        allOf(containsPair('level', 'B2'), containsPair('transcript', null)),
      );
    });

    test('provide empty string', () {
      expect(
        () => WordFile(
          testFile,
          Word(WordPair('test', 'тест')),
          props: {'level': '', 'transcript': null},
          organize: true,
        ),
        throwsArgumentError,
      );
    });
  });
}
