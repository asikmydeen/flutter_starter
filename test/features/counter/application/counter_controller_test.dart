import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/features/counter/application/counter_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Counter', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      addTearDown(container.dispose);
    });

    test('should start at 0', () {
      expect(container.read(counterProvider), 0);
    });

    test('should increase state when increment is called', () {
      container.read(counterProvider.notifier).increment();
      expect(container.read(counterProvider), 1);
    });

    test('should not go below 0 when decrement is called at 0', () {
      container.read(counterProvider.notifier).decrement();
      expect(container.read(counterProvider), 0);
    });

    test('should return to 0 when reset is called', () {
      container.read(counterProvider.notifier)
        ..increment()
        ..increment()
        ..reset();
      expect(container.read(counterProvider), 0);
    });
  });
}
