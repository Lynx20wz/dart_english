import 'dart:convert';

import 'package:http/http.dart' show get;

const baseUrl = 'https://api.dictionaryapi.dev/api/v2/entries/en';

class WordPair {
  final String original;
  final String? translate;

  /// Creates a [WordPair] with trimmed and lowercased [original] and [translate].
  /// This may be provide only one word, then [translate] will be `null`.
  WordPair(String original, [String? translate])
    : original = original.trim().toLowerCase(),
      translate = translate?.trim().toLowerCase();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordPair &&
          original == other.original &&
          translate == other.translate;

  @override
  int get hashCode => original.hashCode ^ (translate?.hashCode ?? 0);

  @override
  String toString() => '$original - $translate';

  bool get isFull => original.isNotEmpty && (translate?.isNotEmpty ?? false);
}

class IrregularVerb {
  final String firstForm, secondForm, thirdForm;

  const IrregularVerb(this.firstForm, this.secondForm, this.thirdForm);

  @override
  String toString() => '`$firstForm` - `$secondForm` - `$thirdForm`';
}

class Word {
  final WordPair mainPair;
  final List<WordPair>? extraPairs;
  final String? enExample, ruExample;
  final IrregularVerb? irregularVerb;
  late String? transcript;
  late List<int>? pronunciationAudio;

  Word(
    this.mainPair, {
    this.extraPairs,
    this.enExample,
    this.ruExample,
    this.transcript,
    this.irregularVerb,
    this.pronunciationAudio,
  });

  /// Syntactic sugar for `Word(WordPair(original))`.
  /// Creating a [Word] with a single word (without translation).
  factory Word.fromWord(String original) => Word(WordPair(original));

  /// Syntactic sugar for `Word(WordPair(original, translate))`.
  /// Creating a [Word] with two words (with translation).
  factory Word.fromWords(String original, String translate) =>
      Word(WordPair(original, translate));

  bool get isFull =>
      mainPair.isFull &&
      enExample != null &&
      ruExample != null &&
      transcript != null &&
      pronunciationAudio != null;

  Future<void> setInfoFromWeb() async {
    if (isFull) return;

    final uri = Uri.parse('$baseUrl/${mainPair.original}');
    final response = await get(uri);
    final json = jsonDecode(response.body);

    if (response.statusCode == 404) {
      if (json['title'] == 'No Definitions Found') {
        throw Exception('Word not found');
      }
      throw Exception('API returned 404');
    }

    while (transcript == null || pronunciationAudio == null) {
      for (final phonetic in json[0]['phonetics']) {
        transcript ??= phonetic['text']?.replaceAll('/', '');
        final pronunciationLink = phonetic['audio'] as String?;

        if (pronunciationLink != null && pronunciationLink.isNotEmpty) {
          final response = await get(
            Uri.parse(pronunciationLink),
          ).then((value) => value);
          pronunciationAudio = response.bodyBytes;
        }
      }
    }
  }
}
