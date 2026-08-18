enum AppRole { user, admin }

final class AuthSession {
  const AuthSession({
    required this.userId,
    required this.tenantId,
    required this.role,
  });

  final String userId;
  final String tenantId;
  final AppRole role;

  bool get canInspectDiagnostics => role == AppRole.admin;
  bool get canResolveTenantConflicts => role == AppRole.admin;
}
