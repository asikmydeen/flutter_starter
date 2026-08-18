import 'package:flutter/material.dart';
import 'package:flutter_starter/core/config/app_config.dart';
import 'package:flutter_starter/l10n/gen/app_localizations.dart';

class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.diagnosticsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ListTile(
            title: Text(l10n.environmentLabel),
            subtitle: Text(AppConfig.instance.env),
          ),
          ListTile(
            title: Text(l10n.apiHostLabel),
            subtitle: Text(Uri.parse(AppConfig.instance.apiBaseUrl).host),
          ),
        ],
      ),
    );
  }
}
