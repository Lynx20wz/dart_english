import 'package:english_core/english_core.dart' show Word;
import 'package:english_core/ext.dart';
import 'package:english_helper/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl;

class WordWidget extends StatelessWidget {
  final Word word;

  const WordWidget(this.word, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: () => launchUrl(
          Uri.parse('obsidian://open?file=${word.mainPair.original}.md'),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ListTile(
            title: Text(
              word.mainPair.original.capitalize(),
              style: theme.textTheme.titleMedium,
            ),
            subtitle: Text(
              word.mainPair.translate ?? '-',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: () => openScreen(
                    context,
                    Screen.search,
                    word.mainPair.original,
                  ),
                  color: theme.colorScheme.outline,
                  // size: 24,
                ),
                Icon(Icons.chevron_right, color: theme.colorScheme.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
