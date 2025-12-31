import 'package:flutter/material.dart';

class HomePageScreen extends StatelessWidget {
  const HomePageScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        spacing: 24,
        children: [
          SizedBox(height: 10),
          Text(
            'English helper',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          Column(
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/words'),
                child: const Text('Words', style: TextStyle(fontSize: 24)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/pronunciation'),
                child: const Text(
                  'Pronunciation',
                  style: TextStyle(fontSize: 24),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
