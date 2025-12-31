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
  late final List<WordPair> wordPairs;
  late final WordPair mainPair;
  final String? enExample, ruExample;
  String? transcript, level;
  final IrregularVerb? irregularVerb;
  late final List<int>? pronunciationAudio;

  Word(
    List<WordPair> pairs, {
    this.enExample,
    this.ruExample,
    this.transcript,
    this.level,
    this.irregularVerb,
    this.pronunciationAudio,
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
      pronunciationAudio != null;

  Future<void> setInfoFromWeb() async {
    if (isFull) return; // to avoid spamming the API

    final webParser = WebParser(mainPair.enWord);

    level = await webParser.getLevel();
    transcript = await webParser.getTranscript();
    pronunciationAudio = await webParser.getPronunciation();
  }

  void savePronunciation() {
    if (pronunciationAudio == null) return;

    final audioFile = File(
      'D:/Programs/Obsidian/data/Мой камень/Кэш/слова/${mainPair.enWord}.mp3',
    );

    audioFile.writeAsBytes(pronunciationAudio!);
  }
}
