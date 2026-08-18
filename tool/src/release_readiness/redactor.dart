import 'dart:convert';

/// Redacts registered credentials and common transformed representations.
final class SecretRedactor {
  final Set<String> _variants = {};

  /// Adds a secret without retaining metadata about its purpose.
  void register(String secret) {
    if (secret.length < 4) {
      throw ArgumentError.value(secret.length, 'secret', 'must be >= 4 chars');
    }
    final jsonEscaped = jsonEncode(secret);
    _variants
      ..add(secret)
      ..add(base64.encode(utf8.encode(secret)))
      ..add(base64Url.encode(utf8.encode(secret)))
      ..add(Uri.encodeComponent(secret))
      ..add(jsonEscaped.substring(1, jsonEscaped.length - 1));
  }

  /// Replaces every registered variant, longest first.
  String redact(String input) {
    final variants = _variants.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    return variants.fold(
      input,
      (value, variant) => value.replaceAll(variant, '[REDACTED]'),
    );
  }
}
