import 'dart:typed_data';

import 'package:english_core/english_core.dart';
import 'package:english_flutter/provider.dart';
import 'package:english_flutter/widgets/back_fab.dart';
import 'package:english_flutter/widgets/pronunciation_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PronunciationScreen extends ConsumerStatefulWidget {
  const PronunciationScreen({super.key});

  @override
  ConsumerState<PronunciationScreen> createState() =>
      _PronunciationScreenState();
}

class _PronunciationScreenState extends ConsumerState<PronunciationScreen> {
  late final TextEditingController _wordController;
  late final FocusNode _focusNode;
  String? _transcript;
  Uint8List? _pronunciation;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _wordController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _wordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _searchTranscript() async {
    final word = _wordController.text.trim();
    if (word.isEmpty) return;

    setState(() {
      _isLoading = true;
      _transcript = null;
      _pronunciation = null;
    });

    try {
      final parser = WebParser(word);
      final transcript = await parser.getTranscript();
      final pronunciation = await parser.getPronunciation();

      if (mounted) {
        setState(() {
          _transcript = transcript;
          _pronunciation = pronunciation;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pinnedCards = ref.watch(pinnedCardsProvider);

    return Scaffold(
      floatingActionButton: const BackFab(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Text(
                'Get pronunciation',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              _buildWordField(theme),
              const SizedBox(height: 16),

              Column(
                children: [
                  if (_transcript != null)
                    PronunciationCard(
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
      ),
    );
  }

  Widget _buildWordField(ThemeData theme) => Container(
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: _focusNode.hasFocus
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withValues(alpha: 0.2),
        width: 1.5,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _wordController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.text_fields,
                  color: _focusNode.hasFocus
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 24,
                ),
                hintText: 'Enter word...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
              cursorColor: theme.colorScheme.primary,
              onSubmitted: (_) async => await _searchTranscript(),
            ),
          ),
          SizedBox(
            width: 44,
            height: 44,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : IconButton(
                    onPressed: _searchTranscript,
                    icon: const Icon(Icons.search_rounded, size: 24),
                    style: IconButton.styleFrom(
                      foregroundColor: _focusNode.hasFocus
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      animationDuration: Duration.zero,
                    ),
                  ),
          ),
        ],
      ),
    ),
  );

  Widget _buildPinnedCard(PronunciationCard card) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: card.copyWith(autoplay: false),
  );
}
