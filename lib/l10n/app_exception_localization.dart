import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/l10n/gen/app_localizations.dart';

/// Localizes a stable application failure at the presentation boundary.
String localizeAppException(AppLocalizations l10n, AppException exception) =>
    switch (exception.code) {
      AppExceptionCode.network => l10n.networkError,
      AppExceptionCode.api => l10n.apiError(
        exception is ApiException ? exception.statusCode : 0,
      ),
      AppExceptionCode.parsing => l10n.parsingError,
      AppExceptionCode.configuration => l10n.configurationError,
      AppExceptionCode.authentication => l10n.authenticationError,
      AppExceptionCode.storage => l10n.storageError,
      AppExceptionCode.conflict => l10n.conflictError,
      AppExceptionCode.unknown => l10n.unknownError,
    };
