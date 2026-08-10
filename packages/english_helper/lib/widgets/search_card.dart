import 'dart:typed_data' show Uint8List;

import 'package:audioplayers/audioplayers.dart'
    show AudioPlayer, BytesSource, PlayerState;
import 'package:english_helper/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PronunciationCard extends ConsumerStatefulWidget {
  final String _word, _transcription;
  final List<int>? pronunciation;
  final bool autoplay;

  const PronunciationCard(
    this._word,
    this._transcription, {
    this.pronunciation,
    this.autoplay = true,
    super.key,
  });

  String get word => _word;
  String get transcription => _transcription;

  PronunciationCard copyWith({
    String? word,
    String? transcription,
    List<int>? pronunciation,
    bool? autoplay,
    void Function(PronunciationCard card)? onPinned,
  }) => PronunciationCard(
    word ?? _word,
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
  late bool _isPinned;

  /// Whether the card is added to the user's dictionary.
  late bool _isAdded;

  late Color bgColor;
  late Color fgColor;
  late Color secondaryTextColor;

  bool get _isAudiable =>
      widget.pronunciation == null || widget.pronunciation!.isEmpty;

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
    if (_isAudiable) return;

    try {
      if (_isPlaying) {
        await _player.pause();
        return;
      }

      await _player.stop();
      await _player.play(BytesSource(widget.pronunciation! as Uint8List));
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
    _isAdded = ref.watch(
      wordsProvider.select(
        (asyncWords) =>
            asyncWords.value?.any(
              (word) => word.mainPair.original == widget.word,
            ) ??
            false,
      ),
    );

    _isPinned = ref.watch(
      pinnedCardsProvider.select(
        (cards) =>
            cards.any((card) => card.transcription == widget.transcription),
      ),
    );

    final theme = Theme.of(context);

    bgColor = _isAdded ? theme.colorScheme.primary : theme.colorScheme.surface;
    fgColor = _isAdded
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;
    secondaryTextColor = fgColor.withValues(alpha: 0.7);

    return Card(
      margin: EdgeInsets.zero,
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _isAdded
              ? Colors.transparent
              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildPlayButton(theme),
            const SizedBox(width: 16),
            _buildTextColumn(theme),
            const Spacer(),
            _buildPinButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton(ThemeData theme) => IconButton(
    onPressed: _isAudiable ? null : playPronunciation,
    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 20),
    style: IconButton.styleFrom(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  Widget _buildTextColumn(ThemeData theme) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget._transcription,
          style: theme.textTheme.titleLarge?.copyWith(color: fgColor),
        ),
        const SizedBox(height: 8),
        Text(
          widget._word,
          style: theme.textTheme.bodyLarge?.copyWith(color: secondaryTextColor),
        ),
      ],
    ),
  );

  Widget _buildPinButton(ThemeData theme) => IconButton(
    highlightColor: fgColor.withValues(alpha: 0.3),
    hoverColor: fgColor.withValues(alpha: 0.2),
    onPressed: () {
      final notifier = ref.read(pinnedCardsProvider.notifier);
      notifier.toggle(widget);
    },
    icon: Icon(
      _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
      size: 20,

      color: _isAdded
          ? theme.colorScheme.onPrimary
          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
    ),
  );
}
