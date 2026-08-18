import 'package:flutter_riverpod/flutter_riverpod.dart';

final class DiagnosticEvent {
  const DiagnosticEvent({
    required this.name,
    required this.correlationId,
    required this.fields,
  });

  final String name;
  final String correlationId;
  final Map<String, Object?> fields;
}

abstract interface class DiagnosticEventSink {
  Future<void> record(DiagnosticEvent event);
  Future<void> flush();
}

final class NoopDiagnosticEventSink implements DiagnosticEventSink {
  const NoopDiagnosticEventSink();

  @override
  Future<void> record(DiagnosticEvent event) async {}

  @override
  Future<void> flush() async {}
}

final diagnosticEventSinkProvider = Provider<DiagnosticEventSink>(
  (ref) => const NoopDiagnosticEventSink(),
);
