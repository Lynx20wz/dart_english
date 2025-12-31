import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:english_core/english_core.dart';
import 'package:english_flutter/widgets/back_fab.dart';
import 'package:flutter/material.dart';

class PronunciationScreen extends StatefulWidget {
  const PronunciationScreen({super.key});

  @override
  State<PronunciationScreen> createState() => _PronunciationScreenState();
}

class _PronunciationScreenState extends State<PronunciationScreen> {
  late final TextEditingController _wordController;
  late final FocusNode _focusNode;
  late final AudioPlayer _player;
  String? _foundTranscript;
  Uint8List? _pronunciation;
  bool _isLoading = false;
  bool _isPlaying = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _wordController = TextEditingController();
    _focusNode = FocusNode();
    _player = AudioPlayer();

    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });

    _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });
  }

  @override
  void dispose() {
    _wordController.dispose();
    _focusNode.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _searchTranscript() async {
    final word = _wordController.text.trim();
    if (word.isEmpty) return;

    setState(() {
      _isLoading = true;
      _foundTranscript = null;
      _pronunciation = null;
    });

    try {
      final parser = WebParser(word);
      final transcript = await parser.getTranscript();
      final pronunciation = await parser.getPronunciation();

      if (mounted) {
        setState(() {
          _foundTranscript = transcript;
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _playPronunciation() async {
    if (_pronunciation == null || _pronunciation!.isEmpty) return;

    try {
      if (_isPlaying) {
        await _player.pause();
        return;
      }

      await _player.stop();
      await _player.play(BytesSource(_pronunciation!));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Playback error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

              if (_foundTranscript != null) _buildResultCard(theme),

              const Spacer(),
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
        color: _isFocused
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
                  color: _isFocused
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
              onSubmitted: (_) async {
                await _searchTranscript();
                await _playPronunciation();
              },
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
                      foregroundColor: _isFocused
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

  Widget _buildResultCard(ThemeData theme) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: theme.colorScheme.primary.withValues(alpha: 0.3),
      ),
      color: theme.colorScheme.surfaceContainerHighest,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _playPronunciation,
          icon: _isPlaying
              ? const Icon(Icons.pause, size: 20)
              : const Icon(Icons.play_arrow, size: 20),
          color: theme.colorScheme.onPrimary,
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            _foundTranscript!,
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'IPA',
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    ),
  );
}
