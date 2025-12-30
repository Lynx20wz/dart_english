import 'package:flutter/material.dart';

class PronunciationScreen extends StatelessWidget {
  const PronunciationScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(hintText: 'Pronunciation'),
                style: TextStyle(fontSize: 20),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.search),
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.blue),
                foregroundColor: WidgetStatePropertyAll(Colors.black),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => Navigator.pop(context),
      child: const Icon(Icons.arrow_back),
    ),
  );
}
