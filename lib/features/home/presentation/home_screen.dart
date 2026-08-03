import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Starter')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Feature-first + Riverpod + go_router'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.goNamed('counter'),
              child: const Text('Open counter demo'),
            ),
          ],
        ),
      ),
    );
  }
}
