import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/src/release_readiness/redactor.dart';

void main() {
  test('should redact raw and transformed credential values', () {
    const secret = 'p8-secret+/value';
    final redactor = SecretRedactor()..register(secret);
    final input = [
      secret,
      base64.encode(utf8.encode(secret)),
      base64Url.encode(utf8.encode(secret)),
      Uri.encodeComponent(secret),
      jsonEncode(secret),
    ].join(' ');

    final output = redactor.redact(input);

    expect(output, isNot(contains(secret)));
    expect(output, isNot(contains(base64.encode(utf8.encode(secret)))));
    expect(output, contains('[REDACTED]'));
  });

  test('should reject values too short to redact safely', () {
    expect(() => SecretRedactor().register('abc'), throwsArgumentError);
  });
}
