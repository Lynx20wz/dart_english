import 'package:flutter/material.dart';

class BackFab extends StatelessWidget {
  const BackFab({super.key});

  @override
  Widget build(BuildContext context) => FloatingActionButton(
    foregroundColor: Colors.white,
    onPressed: () => Navigator.pop(context),
    child: const Icon(Icons.arrow_back),
  );
}
