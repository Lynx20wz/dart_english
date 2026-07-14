import 'dart:convert' hide json;
import 'dart:io' show sleep;
import 'dart:typed_data' show Uint8List;

import 'package:http/http.dart' show get;

const baseUrl = 'https://api.dictionaryapi.dev/api/v2/entries/en';

enum PartOfSpeech {
  noun,
  pronoun,
  verb,
  adjective,
  adverb,
  conjunction,
  preposition;

  factory PartOfSpeech.fromString(String name) =>
      values.firstWhere((e) => e.name == name);
}

class WordPair {
  final String original;
  final String? translation;

  /// Creates a [WordPair] with trimmed and lowercased [original] and [translate].
  /// This may be provide only one word, then [translate] will be `null`.
  WordPair(String original, [String? translate])
    : original = original.trim().toLowerCase(),
      translation = translate?.trim().toLowerCase();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordPair &&
          original == other.original &&
          translation == other.translation;

  @override
  int get hashCode => original.hashCode ^ (translation?.hashCode ?? 0);

  @override
  String toString() => '$original - $translation';

  bool get isFull => original.isNotEmpty && (translation?.isNotEmpty ?? false);

  Map<String, dynamic> toMap() => {
    'original': original,
    'translation': translation,
  };

  WordPair.fromMap(Map<String, dynamic> map)
    : original = map['original'],
      translation = map['translation'];
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
  final String? originalExample, translationExample;
  final IrregularVerb? irregularVerb;
  late PartOfSpeech? partOfSpeech;
  late String? transcription;
  late Uint8List? pronunciationAudio;

  Word(
    this.mainPair, {
    this.extraPairs,
    this.originalExample,
    this.translationExample,
    this.transcription,
    this.irregularVerb,
    this.pronunciationAudio,
    this.partOfSpeech,
  });

  /// Syntactic sugar for `Word(WordPair(original))`.
  /// Creating a [Word] with a single word (without translation).
  factory Word.fromWord(String original) => Word(WordPair(original));

  /// Syntactic sugar for `Word(WordPair(original, translate))`.
  /// Creating a [Word] with two words (with translation).
  factory Word.fromWords(String original, String translate) =>
      Word(WordPair(original, translate));

  factory Word.fromMap(Map<String, dynamic> map) => Word(
    WordPair(map['original'] as String, map['translation'] as String?),
    originalExample: map['original_example'] as String?,
    translationExample: map['translation_example'] as String?,
    transcription: map['transcription'] as String?,
    pronunciationAudio: map['pronunciationAudio'] as Uint8List?,
    partOfSpeech: map['partOfSpeech'] == null
        ? null
        : PartOfSpeech.fromString(map['partOfSpeech'] as String),
  );

  Map<String, dynamic> toMap() => {
    'original': mainPair.original,
    'translation': mainPair.translation,
    'original_example': originalExample,
    'translation_example': translationExample,
    'trancsription': transcription,
    'pronunciationAudio': pronunciationAudio,
    'partOfSpeech': partOfSpeech?.name,
  };

  @override
  String toString() => 'Word(${mainPair.original} [$transcription])';

  bool get isFull =>
      mainPair.isFull &&
      originalExample != null &&
      translationExample != null &&
      transcription != null &&
      pronunciationAudio != null &&
      partOfSpeech != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Word &&
          mainPair == other.mainPair &&
          originalExample == other.originalExample &&
          translationExample == other.translationExample &&
          transcription == other.transcription &&
          irregularVerb == other.irregularVerb &&
          partOfSpeech == other.partOfSpeech);

  @override
  int get hashCode => Object.hash(
    mainPair,
    originalExample,
    translationExample,
    transcription,
    irregularVerb,
    partOfSpeech,
  );

  Future<void> setInfoFromWeb({int maxRetries = 3}) async {
    if (isFull) return;

    final encodedWord = Uri.encodeComponent(mainPair.original);
    final uri = Uri.parse('$baseUrl/$encodedWord');

    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        final response = await get(uri);

        if (response.statusCode == 404) {
          print('⚠️ Word not found: ${mainPair.original}');
          return;
        }

        if (response.statusCode == 429) {
          attempts++;
          if (attempts >= maxRetries) {
            print(
              '❌ Rate limit exceeded. Max retries reached for: ${mainPair.original}',
            );
            return;
          }
          print(
            '⏳ Rate limit exceeded. Waiting 10 seconds... (Attempt $attempts/$maxRetries)',
          );

          await Future.delayed(const Duration(seconds: 10));
          continue;
        }

        if (response.statusCode != 200) {
          print('❌ API returned unexpected status: ${response.statusCode}');
          return;
        }

        final List<dynamic> json;
        try {
          json = jsonDecode(response.body) as List<dynamic>;
        } on FormatException {
          print('❌ Failed to parse JSON for: ${mainPair.original}');
          return;
        }

        if (json.isEmpty) return;

        final firstEntry = json[0] as Map<String, dynamic>;

        final phonetics = firstEntry['phonetics'] as List<dynamic>? ?? [];
        for (final phonetic in phonetics) {
          final text = phonetic['text'] as String?;
          if (transcription == null && text != null && text.isNotEmpty) {
            transcription = text.replaceAll(RegExp(r'[/\[\]]'), '').trim();
          }
        }

        final meanings = firstEntry['meanings'] as List<dynamic>? ?? [];
        if (meanings.isNotEmpty) {
          final firstMeaning = meanings[0] as Map<String, dynamic>;
          final posString = firstMeaning['partOfSpeech'] as String?;

          if (posString != null) {
            partOfSpeech = PartOfSpeech.fromString(posString);
          }
        }

        break;
      } catch (e) {
        attempts++;
        print('⚠️ Network error for ${mainPair.original}: $e');

        if (attempts < maxRetries) {
          await Future.delayed(const Duration(seconds: 5));
        } else {
          print('❌ Max retries reached due to network errors.');
        }
      }
    }
  }
}
