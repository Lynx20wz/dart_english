import 'dart:typed_data';

import 'package:english_core/classes/classes.dart' show Word;
import 'package:html/dom.dart' show Document;
import 'package:html/parser.dart';
import 'package:http/http.dart' show get;
import 'package:translator/translator.dart';

class WebParser {
  static const _baseUrl = 'https://dictionary.cambridge.org';
  final Future<Document> _document;

  final Word word;

  WebParser(this.word)
    : _document = get(
        Uri.parse('$_baseUrl/dictionary/english/$word'),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36',
        },
      ).then((value) => parse(value.body));

  Future<String?> getLevel() async =>
      (await _document).querySelector('.epp-xref.dxref')?.text;

  @Deprecated('Not working now')
  Future<String?> getTranscript() async {
    final translator = GoogleTranslator();
    final response = await translator.translate(
      word.mainPair.original,
      to: 'ru',
    );
    return response.text;
  }

  Future<Uint8List?> getPronunciation() async {
    final pronunciationUrl = (await _document)
        .querySelectorAll('source[type="audio/mpeg"]')[1]
        .attributes['src'];

    if (pronunciationUrl != null) {
      return await get(
        Uri.parse(_baseUrl + pronunciationUrl),
      ).then((value) => value.bodyBytes);
    }

    return null;
  }

  Future<void> setInfoFromWeb() async {
    if (word.isFull) return; // to avoid spamming the API

    word.level = await getLevel();
    // WIP: While `getTranscript()` doesn't work
    word.transcript = null; // await getTranscript();
    word.pronunciationAudio = await getPronunciation();
  }
}
