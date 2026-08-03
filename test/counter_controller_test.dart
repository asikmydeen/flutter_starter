import 'package:flutter_starter/features/counter/application/counter_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CounterController', () {
    test('starts at 0', () {
      expect(CounterController().state, 0);
    });

    test('increment increases state', () {
      final c = CounterController()..increment();
      expect(c.state, 1);
    });

    test('decrement never goes below 0', () {
      final c = CounterController()..decrement();
      expect(c.state, 0);
    });
  });
}
