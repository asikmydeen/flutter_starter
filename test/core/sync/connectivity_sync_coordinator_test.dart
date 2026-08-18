import 'dart:async';

import 'package:flutter_starter/core/sync/connectivity_sync_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should synchronize once when connectivity returns', () async {
    final availability = StreamController<NetworkAvailability>();
    addTearDown(availability.close);
    var calls = 0;
    final coordinator = ConnectivitySyncCoordinator(
      availability.stream,
      () async => calls++,
    )..start();
    addTearDown(coordinator.dispose);

    availability
      ..add(NetworkAvailability.online)
      ..add(NetworkAvailability.offline)
      ..add(NetworkAvailability.online)
      ..add(NetworkAvailability.online);
    await pumpEventQueue();

    expect(calls, 1);
  });

  test('should not overlap reconnect synchronization', () async {
    final availability = StreamController<NetworkAvailability>();
    addTearDown(availability.close);
    final syncCompleter = Completer<void>();
    var calls = 0;
    final coordinator = ConnectivitySyncCoordinator(
      availability.stream,
      () {
        calls++;
        return syncCompleter.future;
      },
    )..start();
    addTearDown(coordinator.dispose);

    availability
      ..add(NetworkAvailability.offline)
      ..add(NetworkAvailability.online)
      ..add(NetworkAvailability.offline)
      ..add(NetworkAvailability.online);
    await pumpEventQueue();
    syncCompleter.complete();
    await pumpEventQueue();

    expect(calls, 1);
  });

  test('should allow idempotent start and disposal', () async {
    final availability = StreamController<NetworkAvailability>();
    addTearDown(availability.close);
    final coordinator =
        ConnectivitySyncCoordinator(
            availability.stream,
            () async {},
          )
          ..start()
          ..start();

    await coordinator.dispose();
    await coordinator.dispose();

    expect(availability.hasListener, isFalse);
  });
}
