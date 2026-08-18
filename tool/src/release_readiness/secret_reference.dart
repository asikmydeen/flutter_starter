import 'dart:io';

import 'digest.dart';

/// A reference to credential material. The value itself is never persisted.
sealed class SecretReference {
  const SecretReference();

  /// Parses supported `file://` and `keychain://` references.
  factory SecretReference.parse(String value) {
    if (value.startsWith('file://')) {
      return FileSecretReference(value.substring('file://'.length));
    }
    if (value.startsWith('keychain://')) {
      final parts = value.substring('keychain://'.length).split('/');
      if (parts.length < 2 || parts.any((part) => part.isEmpty)) {
        throw const FormatException(
          'keychain reference must contain service/account',
        );
      }
      return KeychainSecretReference(parts.first, parts.sublist(1).join('/'));
    }
    throw const FormatException(
      'secret reference must use file:// or keychain://',
    );
  }

  /// Validates metadata without exposing the credential.
  SecretReferenceValidation validate({required Directory repositoryRoot});
}

/// Reference to a permission-restricted file outside the repository.
final class FileSecretReference extends SecretReference {
  const FileSecretReference(this.path);

  final String path;

  @override
  SecretReferenceValidation validate({required Directory repositoryRoot}) {
    final file = File(_expandHome(path));
    if (!file.existsSync()) {
      return const SecretReferenceValidation.invalid(
        'secret file does not exist',
      );
    }
    if (Link(file.path).existsSync()) {
      return const SecretReferenceValidation.invalid(
        'secret file cannot be a symlink',
      );
    }
    final resolvedFile = file.resolveSymbolicLinksSync();
    final resolvedRoot = repositoryRoot.resolveSymbolicLinksSync();
    if (_isWithin(resolvedRoot, resolvedFile)) {
      return const SecretReferenceValidation.invalid(
        'secret file must live outside the repository',
      );
    }
    final fileMode = file.statSync().mode & 0x1FF;
    final directoryMode = file.parent.statSync().mode & 0x1FF;
    if (fileMode != 0x180) {
      return SecretReferenceValidation.invalid(
        'secret file permissions must be 0600 '
        '(found ${fileMode.toRadixString(8)})',
      );
    }
    if (directoryMode != 0x1C0) {
      return SecretReferenceValidation.invalid(
        'secret directory permissions must be 0700 '
        '(found ${directoryMode.toRadixString(8)})',
      );
    }
    return SecretReferenceValidation.valid(
      fingerprintSecret(file.readAsBytesSync()),
    );
  }
}

/// Reference to an operating-system keychain item.
final class KeychainSecretReference extends SecretReference {
  const KeychainSecretReference(this.service, this.account);

  final String service;
  final String account;

  @override
  SecretReferenceValidation validate({required Directory repositoryRoot}) =>
      const SecretReferenceValidation.valid('keychain-managed');
}

/// Redacted result of validating a secret reference.
final class SecretReferenceValidation {
  const SecretReferenceValidation._({
    required this.isValid,
    this.fingerprint,
    this.error,
  });

  const SecretReferenceValidation.valid(String fingerprint)
    : this._(isValid: true, fingerprint: fingerprint);

  const SecretReferenceValidation.invalid(String error)
    : this._(isValid: false, error: error);

  final bool isValid;
  final String? fingerprint;
  final String? error;
}

String _expandHome(String value) {
  if (!value.startsWith(r'$HOME/')) return value;
  return '${Platform.environment['HOME']}/${value.substring(r'$HOME/'.length)}';
}

bool _isWithin(String parent, String child) {
  final normalizedParent = parent.endsWith(Platform.pathSeparator)
      ? parent
      : '$parent${Platform.pathSeparator}';
  return child == parent || child.startsWith(normalizedParent);
}
