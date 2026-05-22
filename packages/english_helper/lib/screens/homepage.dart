import 'package:english_core/english_core.dart';
import 'package:english_helper/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl;

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  String _formatStatusMsg = '';

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      toastification.dismissAll(delayForAnimation: false);
      if (mounted && ModalRoute.of(context)?.isCurrent == true)
        _showUpdateToast(context);
    });

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 16,
            child: Text(_formatStatusMsg, textAlign: TextAlign.center),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 400),
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          child: Icon(
                            Icons.language,
                            size: 60,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        SizedBox(height: 24),

                        Text(
                          'English helper',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),

                        SizedBox(height: 36),

                        FilledButton.icon(
                          onPressed: () => openScreen(context, .words),
                          icon: Icon(Icons.list, size: 28),
                          label: Text(
                            'Vocabulary list',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: FilledButton.styleFrom(
                            minimumSize: Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        TextButton.icon(
                          onPressed: () => openScreen(context, .pronunciation),
                          icon: Icon(Icons.audiotrack, size: 28),
                          label: Text(
                            'Get pronunciation',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Open dictionary folder',
                onPressed: () =>
                    launchUrl(Uri.parse('file://${Config.dictionaryPath}')),
                icon: Icon(
                  Icons.folder,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                hoverColor: Colors.transparent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showUpdateToast(BuildContext context) => toastification.show(
    title: Text(
      'Update vocabulary',
      style: Theme.of(context).textTheme.titleMedium,
    ),
    alignment: Alignment.topCenter,
    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    borderSide: .none,
    type: .info,
    closeButton: ToastCloseButton(
      buttonBuilder: (_, onClose) => IconButton(
        icon: Icon(Icons.refresh),
        onPressed: () => _formatAllFiles(),
        padding: .zero,
      ),
    ),
    showIcon: false,
  );

  void _formatAllFiles() async {
    final parser = DictParser();
    final files = parser.parseAllFiles();
    final totalCount = files.length;
    await for (final (i, file) in parser.formatAllFiles(files: files)) {
      setState(
        () => _formatStatusMsg =
            '(${i + 1}/$totalCount) ${file.word.mainPair.original}',
      );
    }
  }
}
