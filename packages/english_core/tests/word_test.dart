import 'package:english_core/english_core.dart';
import 'package:test/test.dart';

void main() {
  group('pairs check', () {
    test('only one pair', () {
      final pair = const WordPair('hello', 'привет');
      final word = Word(pair);

      expect(word.mainPair, pair);
    });
    test('two pairs', () {
      final word = Word(
        const WordPair('able', 'в состоянии'),
        extraPairs: [const WordPair('able', 'умеющий')],
      );

      expect(word.mainPair, const WordPair('able', 'в состоянии'));
      expect(word.extraPairs, [const WordPair('able', 'умеющий')]);
    });
    test('multiple pairs', () {
      final word = Word(
        const WordPair('acquisition', 'приобретение'),
        extraPairs: [
          const WordPair('to acquire', 'приобретать'),
          const WordPair('acquire', 'приобретённый (дар)'),
        ],
      );

      expect(word.mainPair, const WordPair('acquisition', 'приобретение'));
      expect(word.extraPairs, [
        const WordPair('to acquire', 'приобретать'),
        const WordPair('acquire', 'приобретённый (дар)'),
      ]);
    });
  });

  test('irregular verb', () {
    final word = Word(
      const WordPair('come', 'приходить'),
      irregularVerb: const IrregularVerb('come', 'came', 'come'),
    );

    expect(word.mainPair.toString(), 'come - приходить');
    expect(word.irregularVerb.toString(), 'come - came - come');
  });
}
