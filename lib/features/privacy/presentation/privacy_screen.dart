import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/features/privacy/application/consent_controller.dart';
import 'package:flutter_starter/l10n/gen/app_localizations.dart';

class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final consent = ref.watch(consentControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SwitchListTile(
            title: Text(l10n.analyticsConsentTitle),
            subtitle: Text(l10n.analyticsConsentDescription),
            value: consent,
            onChanged: (enabled) =>
                ref.read(consentControllerProvider.notifier).analyticsConsent =
                    enabled,
          ),
          ListTile(
            title: Text(l10n.deleteLocalDataTitle),
            subtitle: Text(l10n.deleteLocalDataDescription),
          ),
        ],
      ),
    );
  }
}
