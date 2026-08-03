import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/core/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('should return the value from valueOrThrow on Success', () {
      const result = Success<int>(42);
      expect(result.valueOrThrow, 42);
    });

    test('should throw the typed error from valueOrThrow on Failure', () {
      const result = Failure<int>(NetworkException());
      expect(() => result.valueOrThrow, throwsA(isA<NetworkException>()));
    });

    test('should transform the value with map on Success', () {
      const result = Success<int>(2);
      final mapped = result.map((v) => v * 2);
      expect((mapped as Success<int>).value, 4);
    });

    test('should pass the failure through unchanged with map', () {
      const result = Failure<int>(NetworkException());
      final mapped = result.map((v) => v * 2);
      expect((mapped as Failure<int>).error, isA<NetworkException>());
    });
  });
}
