import 'package:english_flutter/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_size/window_size.dart';

void main() {
  runApp(ProviderScope(child: const App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    setWindowMinSize(const Size(300, 300));
    return MaterialApp(
      routes: {
        '/words': (context) => const WordsListScreen(),
        '/pronunciation': (context) => const PronunciationScreen(),
      },
      title: 'English helper',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(primary: Colors.blue),
      ),
      home: const HomePageScreen(),
    );
  }
}
