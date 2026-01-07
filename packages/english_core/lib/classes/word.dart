import 'dart:io';

import '../parsers/web_parser.dart';

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
  final WordPair mainPair;
  final List<WordPair> wordPairs;
  String? enExample, ruExample;
  final IrregularVerb? irregularVerb;
  late final String? transcript, level;
  late final List<int>? pronunciationAudio;

  Word(
    List<WordPair> pairs, {
    this.enExample,
    this.ruExample,
    this.transcript,
    this.level,
    this.irregularVerb,
    this.pronunciationAudio,
  }) : mainPair = pairs[0],
       wordPairs = pairs.sublist(1);

  static Future<Word> fromWeb(WordPair pair) async {
    final word = Word([pair]);
    await word.setInfoFromWeb();
    return word;
  }

  Future<void> setInfoFromWeb() async {
    if (isFull) return; // to avoid spamming the API

    final webParser = WebParser(mainPair.enWord);

    level = await webParser.getLevel();
    transcript = await webParser.getTranscript();
    pronunciationAudio = await webParser.getPronunciation();
  }

  bool get isFull =>
      mainPair.isFull &&
      enExample != null &&
      ruExample != null &&
      level != null &&
      transcript != null &&
      pronunciationAudio != null;

  void savePronunciation() {
    if (pronunciationAudio == null) return;

    final audioFile = File(
      'D:/Programs/Obsidian/data/Мой камень/Кэш/слова/${mainPair.enWord}.mp3',
    );

    audioFile.writeAsBytes(pronunciationAudio!);
  }
}
