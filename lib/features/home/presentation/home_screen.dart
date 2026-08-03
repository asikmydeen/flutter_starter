import 'package:flutter/material.dart';
import 'package:flutter_starter/core/router/app_router.dart';
import 'package:flutter_starter/l10n/gen/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// Landing screen linking to the demo features.
class HomeScreen extends StatelessWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.homeTagline, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.goNamed(RouteNames.counter),
                child: Text(l10n.openCounterButton),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.goNamed(RouteNames.todos),
                child: Text(l10n.openTodosButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
