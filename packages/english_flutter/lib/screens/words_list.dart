import 'package:english_flutter/widgets/back_fab.dart';
import 'package:english_flutter/widgets/word_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider.dart';

class WordsListScreen extends ConsumerWidget {
  const WordsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final words = ref.watch(wordsProvider);

    return Scaffold(
      body: ListView.builder(
        itemCount: words.length,
        itemBuilder: (context, index) => WordWidget(words[index]),
      ),
      floatingActionButton: BackFab(),
    );
  }
}
