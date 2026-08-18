import 'dart:async';

/// Connectivity state reduced to whether a sync attempt is worthwhile.
enum NetworkAvailability { offline, online }

/// Triggers synchronization when the app transitions back online.
final class ConnectivitySyncCoordinator {
  ConnectivitySyncCoordinator(this._availability, this._synchronize);

  final Stream<NetworkAvailability> _availability;
  final Future<void> Function() _synchronize;
  StreamSubscription<NetworkAvailability>? _subscription;
  NetworkAvailability? _previous;
  bool _synchronizing = false;

  void start() {
    if (_subscription != null) return;
    _subscription = _availability.listen((current) async {
      final reconnected =
          _previous == NetworkAvailability.offline &&
          current == NetworkAvailability.online;
      _previous = current;
      if (!reconnected || _synchronizing) return;
      _synchronizing = true;
      try {
        await _synchronize();
      } finally {
        _synchronizing = false;
      }
    });
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
