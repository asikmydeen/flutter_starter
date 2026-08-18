import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/observability/diagnostic_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should retain structured non-sensitive diagnostic fields', () async {
    const event = DiagnosticEvent(
      name: 'todos_sync_completed',
      correlationId: 'correlation-id',
      fields: {'pulled': 2, 'pushed': 1},
    );
    const sink = NoopDiagnosticEventSink();

    await sink.record(event);
    await sink.flush();

    expect(event.name, 'todos_sync_completed');
    expect(event.correlationId, 'correlation-id');
    expect(event.fields['pulled'], 2);
  });

  test('should expose a safe no-op sink before Firebase is configured', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(diagnosticEventSinkProvider),
      isA<NoopDiagnosticEventSink>(),
    );
  });
}
