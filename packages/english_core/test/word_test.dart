import 'package:english_core/english_core.dart';
import 'package:test/test.dart';

void main() {
  group('pairs check', () {
    test('only one pair', () {
      final pair = WordPair('hello', 'привет');
      final word = Word(pair);

      expect(word.mainPair, pair);
    });
    test('two pairs', () {
      final word = Word(
        WordPair('able', 'в состоянии'),
        extraPairs: [WordPair('able', 'умеющий')],
      );

      expect(word.mainPair, WordPair('able', 'в состоянии'));
      expect(word.extraPairs, [WordPair('able', 'умеющий')]);
    });
    test('multiple pairs', () {
      final word = Word(
        WordPair('acquisition', 'приобретение'),
        extraPairs: [
          WordPair('to acquire', 'приобретать'),
          WordPair('acquire', 'приобретённый (дар)'),
        ],
      );

      expect(word.mainPair, WordPair('acquisition', 'приобретение'));
      expect(word.extraPairs, [
        WordPair('to acquire', 'приобретать'),
        WordPair('acquire', 'приобретённый (дар)'),
      ]);
    });
  });

  test('irregular verb', () {
    final word = Word(
      WordPair('come', 'приходить'),
      irregularVerb: const IrregularVerb('come', 'came', 'come'),
    );

    expect(word.mainPair.toString(), 'come - приходить');
    expect(word.irregularVerb.toString(), '`come` - `came` - `come`');
  });

  test('setInfoFromWeb', () async {
    final word = Word(WordPair('hello', 'привет'));
    await word.setInfoFromWeb();

    expect(word.transcript, 'həˈləʊ');
    expect(word.pronunciationAudio, isNotNull);
  });
}
