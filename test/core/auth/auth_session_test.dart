import 'package:flutter_starter/core/auth/auth_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should restrict tenant diagnostics to admins', () {
    const user = AuthSession(
      userId: 'user-1',
      tenantId: 'tenant-1',
      role: AppRole.user,
    );
    const admin = AuthSession(
      userId: 'admin-1',
      tenantId: 'tenant-1',
      role: AppRole.admin,
    );

    expect(user.canInspectDiagnostics, isFalse);
    expect(user.canResolveTenantConflicts, isFalse);
    expect(admin.canInspectDiagnostics, isTrue);
    expect(admin.canResolveTenantConflicts, isTrue);
  });
}
