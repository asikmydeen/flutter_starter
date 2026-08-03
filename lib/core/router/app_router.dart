import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/features/counter/presentation/counter_screen.dart';
import 'package:flutter_starter/features/home/presentation/home_screen.dart';
import 'package:flutter_starter/features/todos/presentation/todos_screen.dart';
import 'package:flutter_starter/l10n/gen/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// Route names — always navigate with `context.goNamed(RouteNames.x)`,
/// never with raw path strings.
abstract final class RouteNames {
  /// Home screen.
  static const home = 'home';

  /// Counter demo.
  static const counter = 'counter';

  /// Todos reference feature.
  static const todos = 'todos';
}

/// App router. Add new feature routes here as children of home (or as
/// top-level routes for full-screen flows).
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'counter',
            name: RouteNames.counter,
            builder: (context, state) => const CounterScreen(),
          ),
          GoRoute(
            path: 'todos',
            name: RouteNames.todos,
            builder: (context, state) => const TodosScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(AppLocalizations.of(context).routeNotFound('${state.uri}')),
      ),
    ),
  );
});
