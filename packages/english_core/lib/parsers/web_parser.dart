import 'dart:typed_data';

import 'package:html/dom.dart' show Document;
import 'package:html/parser.dart';
import 'package:http/http.dart' show get;
import 'package:yandex_dictionary_api/yandex_dictionary_api.dart';

import '../classes/config.dart' show Config;

final yandexDictKey = YandexDictionaryKey(apiKey: Config.yandexApiKey);
final yandexDictApi = YandexDictionaryApi(key: yandexDictKey);

class WebParser {
  static const _baseUrl = 'https://dictionary.cambridge.org';
  final Future<Document> _document;

  final String word;

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

  Future<String?> getTranscript() async {
    final lookupRequest = YandexLookupRequest(lang: 'en-ru', text: word);

    final response = await yandexDictApi.lookup(lookupRequest);
    return response.def?.first.ts;
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
}
