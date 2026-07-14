import 'package:english_helper/widgets/back_fab.dart';
import 'package:english_helper/widgets/search_input.dart' show SearchInput;
import 'package:english_helper/widgets/word_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider.dart';

class WordsListScreen extends ConsumerStatefulWidget {
  const WordsListScreen({super.key});

  @override
  ConsumerState<WordsListScreen> createState() => _WordsListScreenState();
}

class _WordsListScreenState extends ConsumerState<WordsListScreen> {
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final notifier = ref.read(searchQueryProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) => notifier.setQuery(""));
    _searchController.addListener(
      () => notifier.setQuery(_searchController.text),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
      child: ref
          .watch(wordsDBProvider)
          .when(
            data: (words) => Column(
              children: [
                SearchInput(wordController: _searchController),
                Expanded(
                  child: ListView.builder(
                    itemCount: words.length,
                    itemBuilder: (context, index) => WordWidget(words[index]),
                  ),
                ),
              ],
            ),
            loading: () => Center(child: CircularProgressIndicator()),
            error: (e, stack) => Center(child: Text('Error: $e\n$stack')),
          ),
    ),
    floatingActionButton: BackFab(),
  );
}
