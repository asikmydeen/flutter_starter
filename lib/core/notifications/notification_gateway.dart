import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class NotificationGateway {
  Future<void> initialize();
  Stream<Uri> get openedLinks;
}

final class NoopNotificationGateway implements NotificationGateway {
  const NoopNotificationGateway();

  @override
  Future<void> initialize() async {}

  @override
  Stream<Uri> get openedLinks => const Stream.empty();
}

final notificationGatewayProvider = Provider<NotificationGateway>(
  (ref) => const NoopNotificationGateway(),
);
