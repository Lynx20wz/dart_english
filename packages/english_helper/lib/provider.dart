import 'package:english_core/english_core.dart' show Word, DictParser;
import 'package:english_helper/db.dart';
import 'package:english_helper/widgets/search_card.dart';
import 'package:english_helper/wordProvider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' show Database;

final dbProvider = FutureProvider<Database>((ref) => createDatabase());

final wordProvider = FutureProvider<WordProvider>((ref) async {
  final db = await ref.watch(dbProvider.future);
  return WordProvider(db);
});

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

@deprecated
final wordsProvider = Provider<List<Word>>(
  (_) =>
      DictParser().parseAllWords()
        ..sort((a, b) => a.mainPair.original.compareTo(b.mainPair.original)),
);

@deprecated
final filteredWordsProvider = Provider<List<Word>>((ref) {
  final words = ref.watch(wordsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  if (query.isEmpty) return words;
  return words
      .where((w) => w.mainPair.original.toLowerCase().startsWith(query))
      .toList();
});

final wordsDBProvider = FutureProvider<List<Word>>((ref) async {
  final db = await ref.watch(dbProvider.future);
  final query = ref.watch(searchQueryProvider);
  return WordProvider(db).getWords(query);
});

final pinnedCardsProvider =
    NotifierProvider<PinnedCardsNotifier, List<PronunciationCard>>(
      PinnedCardsNotifier.new,
    );

class PinnedCardsNotifier extends Notifier<List<PronunciationCard>> {
  @override
  List<PronunciationCard> build() => [];

  void clear() => state = [];

  void add(PronunciationCard card) {
    if (!state.any((c) => c.word == card.word)) state = [...state, card];
  }

  void remove(PronunciationCard card) =>
      state = state.where((c) => c.word != card.word).toList();

  void toggle(PronunciationCard card) {
    if (state.any((c) => c.word == card.word)) {
      remove(card);
    } else
      add(card);
  }
}
