import 'dart:io' show Process;

import 'package:flutter/material.dart';

class HomePageScreen extends StatelessWidget {
  const HomePageScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
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
                    ).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.language,
                      size: 60,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  SizedBox(height: 24),

                  Text(
                    'English helper',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 36),

                  FilledButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/words'),
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

                  ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/pronunciation'),
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
          onPressed: () => Process.run('explorer', [
            r'D:\programs\Obsidian\data\Мой камень\Обучения\Английский\Слова',
          ]),
          icon: Icon(
            Icons.folder,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          hoverColor: Colors.transparent,
        ),
      ],
    ),
  );
}
