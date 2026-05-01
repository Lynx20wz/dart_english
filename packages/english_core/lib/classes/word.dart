import 'dart:io';

import 'package:english_core/classes/classes.dart';

class WordPair {
  final String original;
  final String? translate;
  const WordPair(this.original, [this.translate]);

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
  late String? transcript, level;
  late List<int>? pronunciationAudio;

  Word(
    this.mainPair, {
    this.extraPairs,
    this.enExample,
    this.ruExample,
    this.transcript,
    this.level,
    this.irregularVerb,
    this.pronunciationAudio,
  });

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
      final audioFile = File(
        '${Config.dictionaryPath}${mainPair.original}.mp3',
      );
      audioFile.writeAsBytes(pronunciationAudio!);
    } else {
      print('No pronunciation audio to save for ${mainPair.original}');
    }
  }
}
