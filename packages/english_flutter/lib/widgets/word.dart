import 'package:english_core/english_core.dart' show Word;
import 'package:flutter/material.dart';

class WordWidget extends StatelessWidget {
  final Word word;

  const WordWidget(this.word, {super.key});

  @override
  Widget build(BuildContext context) =>
      ListTile(title: Text(word.mainPair.enWord));
}
