import 'package:english_core/english_core.dart';
import 'package:english_helper/provider.dart';
import 'package:english_helper/widgets/back_fab.dart';
import 'package:english_helper/widgets/search_card.dart';
import 'package:english_helper/widgets/search_input.dart' show SearchInput;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String? _transcript;
  List<int>? _pronunciation;
  TextEditingController _wordController = TextEditingController();

  /// Returns the trimmed text from the word controller (search input).
  String get _word => _wordController.text.trim();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final word = ModalRoute.of(context)?.settings.arguments as String?;
      if (word != null) _wordController.text = word;
      _searchTranscript();
    });
  }

  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
  }

  Future<void> _searchTranscript() async {
    if (_word.isEmpty) return;

    setState(() {
      _transcript = null;
      _pronunciation = null;
    });

    try {
      final wordObj = Word.fromWord(_word);
      await wordObj.setInfoFromWeb();

      if (mounted) {
        setState(() {
          _transcript = wordObj.transcript;
          _pronunciation = wordObj.pronunciationAudio;
        });
      }
    } catch (e) {
      if (mounted) {
        toastification.show(
          title: Text('Get info error'),
          description: Text(e.toString()),
          alignment: .bottomCenter,
          backgroundColor: Theme.of(context).colorScheme.onSurface,
          borderSide: .none,
          type: .warning,
          showIcon: false,
          autoCloseDuration: Duration(seconds: 3),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // `.read` instead of `.watch` to avoid rebuilding when the list changes.
    // It needs to that unpin cards remain until next search.
    final pinnedCards = ref.read(pinnedCardsProvider);

    return Scaffold(
      floatingActionButton: const BackFab(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Text(
              'Word search',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            SearchInput(
              wordController: _wordController,
              onSearch: _searchTranscript,
            ),
            const SizedBox(height: 16),

            Column(
              children: [
                if (_transcript != null)
                  PronunciationCard(
                    _word,
                    _transcript!,
                    pronunciation: _pronunciation!,
                  ),

                if (pinnedCards.isNotEmpty)
                  ...pinnedCards
                      .where((card) => card.transcription != _transcript)
                      .map(_buildPinnedCard),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinnedCard(PronunciationCard card) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: card.copyWith(autoplay: false),
  );
}
