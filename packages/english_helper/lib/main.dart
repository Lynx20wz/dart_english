import 'package:english_helper/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart' show ToastificationWrapper;

void main() {
  runApp(ProviderScope(child: const App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => ToastificationWrapper(
    child: MaterialApp(
      routes: {
        '/words': (context) => const WordsListScreen(),
        '/search': (context) => const SearchScreen(),
      },

      // debugShowCheckedModeBanner: false,
      title: 'English helper',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: .fromSeed(seedColor: Colors.blue, brightness: .dark),
      ),
      home: const HomePageScreen(),
    ),
  );
}
