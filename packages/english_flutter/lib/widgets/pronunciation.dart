import 'dart:typed_data' show Uint8List;

import 'package:audioplayers/audioplayers.dart'
    show AudioPlayer, BytesSource, PlayerState;
import 'package:english_flutter/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PronunciationCard extends ConsumerStatefulWidget {
  final String _transcription;
  final Uint8List? pronunciation;
  final bool autoplay;

  const PronunciationCard(
    this._transcription, {
    this.pronunciation,
    this.autoplay = true,
    super.key,
  });

  String get transcription => _transcription;

  PronunciationCard copyWith({
    String? transcription,
    Uint8List? pronunciation,
    bool? autoplay,
    bool? isPinned,
    void Function(PronunciationCard card)? onPinned,
  }) => PronunciationCard(
    transcription ?? _transcription,
    pronunciation: pronunciation ?? this.pronunciation,
    autoplay: autoplay ?? this.autoplay,
    key: key,
  );

  @override
  ConsumerState<PronunciationCard> createState() => PronunciationCardState();
}

class PronunciationCardState extends ConsumerState<PronunciationCard> {
  final _player = AudioPlayer();

  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });

    if (widget.autoplay) playPronunciation();
  }

  Future<void> playPronunciation() async {
    if (widget.pronunciation == null || widget.pronunciation!.isEmpty) return;

    try {
      if (_isPlaying) {
        await _player.pause();
        return;
      }

      await _player.stop();
      await _player.play(BytesSource(widget.pronunciation!));
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
    final isPinned = ref
        .watch(pinnedCardsProvider)
        .any((card) => card.transcription == widget.transcription);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.pronunciation != null && widget.pronunciation!.isNotEmpty
                ? IconButton(
                    onPressed: playPronunciation,
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
                  )
                : Icon(
                    Icons.close,
                    size: 20,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget._transcription,
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'IPA',
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () =>
                  ref.read(pinnedCardsProvider.notifier).toggle(widget),
              icon: const Icon(Icons.push_pin, size: 20),
              color: isPinned
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
