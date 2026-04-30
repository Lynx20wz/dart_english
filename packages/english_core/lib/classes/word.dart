import 'dart:io';

import 'package:english_core/classes/classes.dart';

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
  String toString() => '`$firstForm` - `$secondForm` - `$thirdForm`';
}

class Word {
  final WordPair mainPair;
  final List<WordPair> extraWordPairs;
  final String? enExample, ruExample;
  final IrregularVerb? irregularVerb;
  late String? transcript, level;
  late List<int>? pronunciationAudio;

  Word(
    List<WordPair> pairs, {
    this.enExample,
    this.ruExample,
    this.transcript,
    this.level,
    this.irregularVerb,
    this.pronunciationAudio,
  }) : mainPair = pairs[0],
       extraWordPairs = pairs.sublist(1);

  bool get isFull =>
      mainPair.isFull &&
      enExample != null &&
      ruExample != null &&
      level != null &&
      transcript != null &&
      pronunciationAudio != null;

  // it is very doubtful that it should be here.
  void savePronunciation() {
    if (pronunciationAudio != null) {
      final audioFile = File('${Config.dictionaryPath}${mainPair.enWord}.mp3');
      audioFile.writeAsBytes(pronunciationAudio!);
    } else {
      print('No pronunciation audio to save for ${mainPair.enWord}');
    }
  }
}
