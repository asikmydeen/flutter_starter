import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A minimal Riverpod StateNotifier demonstrating the application layer.
class CounterController extends StateNotifier<int> {
  CounterController() : super(0);

  void increment() => state++;
  void decrement() => state = state > 0 ? state - 1 : 0;
  void reset() => state = 0;
}

final counterProvider =
    StateNotifierProvider<CounterController, int>((ref) => CounterController());
