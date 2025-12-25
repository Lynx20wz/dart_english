import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' show Response, get;
import 'package:yandex_dictionary_api/yandex_dictionary_api.dart';

final yandexDictKey = YandexDictionaryKey(
  apiKey:
      'dict.1.1.20251224T174354Z.ab9b47c46457f519.d375900a1f29c5615a2986d7c9afc4c8dc46ee24',
);
final yandexDictApi = YandexDictionaryApi(key: yandexDictKey);

class WordPair {
  final String enWord, ruWord;
  const WordPair(this.enWord, this.ruWord);

  @override
  String toString() => '$enWord - $ruWord';

  bool get isFull => enWord.isNotEmpty && ruWord.isNotEmpty;
}

class IrregularVerb {
  final String firstForm, secondForm, thirdForm;

  const IrregularVerb(this.firstForm, this.secondForm, this.thirdForm);

  @override
  String toString() => '$firstForm - $secondForm - $thirdForm';
}

class Word {
  late final List<WordPair> wordPairs;
  late final WordPair mainPair;
  final String? enExample, ruExample;
  String? transcript, level;
  final IrregularVerb? irregularVerb;
  bool hasPronunciation;

  Word(
    List<WordPair> pairs, {
    this.enExample,
    this.ruExample,
    this.transcript,
    this.level,
    this.irregularVerb,
    this.hasPronunciation = false,
  }) {
    mainPair = pairs[0];
    wordPairs = pairs.sublist(1);
  }

  bool get isFull =>
      mainPair.isFull &&
      enExample != null &&
      ruExample != null &&
      level != null &&
      transcript != null &&
      hasPronunciation;

  Word setInfoFromWeb() {
    WebParser(this).setInfoFromWeb();
    return this;
  }
}

class WebParser {
  static const baseUrl = 'https://dictionary.cambridge.org';
  static const headers = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36',
  };
  final Word word;

  const WebParser(this.word);

  void setInfoFromWeb() async {
    final lookupRequest = YandexLookupRequest(
      lang: 'en-ru',
      text: word.mainPair.enWord,
    );

    final response = await yandexDictApi.lookup(lookupRequest);
    log(response.toString());

    _setLevel(response);
    _setTranscript(response);
    _setPronunciation(response);
  }

  void _setLevel(YandexLookupResponse response) {
    final level = response.def?.first;

    word.level = level;
  }

  void _setTranscript(YandexLookupResponse response) async {
    if (word.transcript != null) return; // to avoid spamming the API

    final transcriptEl = response.querySelector('.ipa.dipa.lpr-2.lpl-1');
    String transcript;

    if (transcriptEl == null) {
      Response response = await get(
        Uri.https(
          'https://dictionary.yandex.net',
          '/dicservice.json/lookupMultiple',
        ),

        headers: headers,
      );

      transcript = jsonDecode(response.body)['en-ru']['regular'][0]['ts'];
    } else {
      transcript = transcriptEl.text;
    }

    word.transcript = transcript;
  }

  void _setPronunciation(YandexLookupResponse response) {}
}
