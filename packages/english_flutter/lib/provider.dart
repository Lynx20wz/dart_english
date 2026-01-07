import 'package:english_core/english_core.dart' show Word, DictParser;
import 'package:english_flutter/widgets/pronunciation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final wordsProvider = Provider<List<Word>>((_) => DictParser().parseAllWords());
final pinnedCardsProvider =
    NotifierProvider<PinnedCardsNotifier, List<PronunciationCard>>(
      PinnedCardsNotifier.new,
    );

class PinnedCardsNotifier extends Notifier<List<PronunciationCard>> {
  @override
  List<PronunciationCard> build() => [];

  void clear() => state = [];

  void add(PronunciationCard card) {
    if (!state.any((c) => c.transcription == card.transcription))
      state = [...state, card];
  }

  void remove(String transcription) => state = state
      .where((card) => card.transcription != transcription)
      .toList();

  void toggle(PronunciationCard card) {
    if (state.any((c) => c.transcription == card.transcription)) {
      remove(card.transcription);
    } else
      add(card);
  }
}
