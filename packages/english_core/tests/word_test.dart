import 'package:english_core/english_core.dart';
import 'package:test/test.dart';

void main() {
  test('Word', () async {
    final pair = const WordPair('hello', 'привет');
    final word = await Word.fromWeb(pair);
    expect(word.mainPair, pair);
    expect(word.transcript, 'həˈləʊ');
  });
}
