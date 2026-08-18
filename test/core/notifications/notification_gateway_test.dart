import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/notifications/notification_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should remain inert before Firebase Messaging is configured', () async {
    const gateway = NoopNotificationGateway();

    await gateway.initialize();

    expect(await gateway.openedLinks.toList(), isEmpty);
  });

  test('should provide the no-op gateway by default', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(notificationGatewayProvider),
      isA<NoopNotificationGateway>(),
    );
  });
}
