import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/features/todos/application/todos_controller.dart';
import 'package:flutter_starter/l10n/app_exception_localization.dart';
import 'package:flutter_starter/l10n/gen/app_localizations.dart';

/// Reference screen: renders every `AsyncValue` state explicitly and
/// surfaces typed error messages with a retry action.
class TodosScreen extends ConsumerWidget {
  /// Creates the todos screen.
  const TodosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final todos = ref.watch(todosControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.todosTitle)),
      body: switch (todos) {
        AsyncData(:final value) => RefreshIndicator(
          onRefresh: () => ref.read(todosControllerProvider.notifier).refresh(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: value.length,
            itemBuilder: (context, index) {
              final todo = value[index];
              return ListTile(
                leading: Icon(
                  todo.completed
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: todo.completed
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(todo.title),
              );
            },
          ),
        ),
        AsyncError(:final error) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                error is AppException
                    ? localizeAppException(l10n, error)
                    : l10n.unknownError,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    ref.read(todosControllerProvider.notifier).refresh(),
                child: Text(l10n.retryButton),
              ),
            ],
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
