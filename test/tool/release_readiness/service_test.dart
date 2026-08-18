import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/src/release_readiness/command_runner.dart';
import '../../../tool/src/release_readiness/github_client.dart';
import '../../../tool/src/release_readiness/model.dart';
import '../../../tool/src/release_readiness/service.dart';
import '../../../tool/src/release_readiness/state_store.dart';

void main() {
  late Directory repository;
  late Directory secrets;
  late File secretFile;
  late FakeCommandRunner runner;
  late ReleaseReadinessService service;

  setUp(() {
    repository = Directory.systemTemp.createTempSync('readiness_service_repo_');
    secrets = Directory.systemTemp.createTempSync('readiness_service_secret_');
    if (!Platform.isWindows) Process.runSync('chmod', ['700', secrets.path]);
    secretFile = File('${secrets.path}/credential.txt')
      ..writeAsStringSync('replacement-credential');
    if (!Platform.isWindows) {
      Process.runSync('chmod', ['600', secretFile.path]);
    }
    Directory('${repository.path}/config').createSync();
    File('${repository.path}/starter.yaml').writeAsStringSync('''
schemaVersion: 1
project:
  packageName: readiness_test
''');
    File(
      '${repository.path}/config/release_readiness.json',
    ).writeAsStringSync(jsonEncode(_manifest(secretFile.path)));
    runner = FakeCommandRunner();
    service = ReleaseReadinessService(
      repositoryRoot: repository,
      store: ReadinessStateStore(
        File('${repository.path}/.release-readiness/state.json'),
      ),
      github: GithubClient(
        repository: 'owner/repository',
        runner: runner,
      ),
    );
  });

  tearDown(() {
    repository.deleteSync(recursive: true);
    secrets.deleteSync(recursive: true);
  });

  test('should block when required answers are missing', () async {
    final manifestFile = File(
      '${repository.path}/config/release_readiness.json',
    );
    final manifest =
        jsonDecode(manifestFile.readAsStringSync())! as Map<String, Object?>;
    final answers = manifest['answers']! as Map<String, Object?>;
    answers['supportEmail'] = '';
    manifestFile.writeAsStringSync(jsonEncode(manifest));

    final state = await service.validate(live: false);

    expect(state.stage, ReadinessStage.draft);
    expect(
      state.blockers.map((blocker) => blocker.checkId),
      contains('answer.supportEmail'),
    );
  });

  test('should persist secret references outside redacted state', () {
    final state = service.answer(
      'secret.appleApiKey',
      'file://${secretFile.path}',
    );
    final references = File('${repository.path}/.env.release.local');

    expect(state.answers['secret.appleApiKey'], 'file reference configured');
    expect(jsonEncode(state.toJson()), isNot(contains(secretFile.path)));
    expect(references.readAsStringSync(), contains(secretFile.path));
    if (!Platform.isWindows) expect(references.statSync().mode & 0x1FF, 0x180);
  });

  test('should plan without mutating GitHub', () async {
    await _supplyEvidence(service);
    final validated = await service.validate(live: true);
    expect(validated.stage, ReadinessStage.resourcesValidated);

    final outcome = await service.configureGithub(confirm: false);

    expect(outcome.plan, hasLength(2));
    expect(runner.calls.where((call) => call.startsWith('gh api')), isEmpty);
    expect(service.status().stage, ReadinessStage.resourcesValidated);
  });

  test(
    'should configure GitHub then bind approval to current inputs',
    () async {
      await _supplyEvidence(service);
      await service.validate(live: true);

      final configured = await service.configureGithub(confirm: true);
      final ready = service.approve();

      expect(configured.state.stage, ReadinessStage.githubConfigured);
      expect(ready.stage, ReadinessStage.ready);
      expect(ready.approvedDigest, ready.inputsDigest);
      expect(
        runner.calls.where((call) => call.startsWith('gh api')),
        hasLength(4),
      );
    },
  );

  test('should block when GitHub environments lack protection', () async {
    runner.protectedEnvironments = false;
    await _supplyEvidence(service);
    await service.validate(live: true);

    final outcome = await service.configureGithub(confirm: true);

    expect(outcome.state.stage, ReadinessStage.resourcesValidated);
    expect(
      outcome.state.blockers.map((blocker) => blocker.checkId),
      contains('github.environmentProtection'),
    );
    expect(service.approve, throwsStateError);
  });

  test('should invalidate READY when the manifest inputs change', () async {
    await _supplyEvidence(service);
    await service.validate(live: true);
    await service.configureGithub(confirm: true);
    service.approve();
    File('${repository.path}/starter.yaml').writeAsStringSync('''
schemaVersion: 1
project:
  packageName: changed
''');

    final state = await service.validate(live: false);

    expect(state.stage, ReadinessStage.answered);
    expect(state.stage, isNot(ReadinessStage.ready));
    expect(state.approvedDigest, isNull);
  });

  test(
    'should leave GitHub untouched when rotation validation fails',
    () async {
      await _supplyEvidence(service);
      await service.validate(live: true);
      await service.configureGithub(confirm: true);
      service.approve();

      await expectLater(
        service.rotate(
          name: 'ASC_API_PRIVATE_KEY_P8',
          environment: 'release-internal',
          replacementReference: 'file://${secrets.path}/missing.p8',
          confirm: true,
        ),
        throwsStateError,
      );
      expect(
        runner.calls.where((call) => call.startsWith('gh secret')),
        isEmpty,
      );
    },
  );

  test(
    'should plan a valid rotation without exposing the credential',
    () async {
      await _supplyEvidence(service);
      await service.validate(live: true);
      await service.configureGithub(confirm: true);
      service.approve();

      final outcome = await service.rotate(
        name: 'ASC_API_PRIVATE_KEY_P8',
        environment: 'release-internal',
        replacementReference: 'file://${secretFile.path}',
        confirm: false,
      );

      expect(outcome.plan.single, contains('ASC_API_PRIVATE_KEY_P8'));
      expect(outcome.plan.single, isNot(contains('replacement-credential')));
      expect(
        runner.calls.where((call) => call.startsWith('gh secret')),
        isEmpty,
      );
    },
  );

  test('should switch a validated rotation using encoded stdin', () async {
    await _supplyEvidence(service);
    await service.validate(live: true);
    await service.configureGithub(confirm: true);
    service.approve();

    final outcome = await service.rotate(
      name: 'ASC_API_PRIVATE_KEY_P8',
      environment: 'release-internal',
      replacementReference: 'file://${secretFile.path}',
      confirm: true,
    );

    expect(
      runner.calls.where((call) => call.startsWith('gh secret')),
      hasLength(1),
    );
    expect(
      runner.standardInputs.single,
      base64.encode(utf8.encode('replacement-credential')),
    );
    expect(
      outcome.state.pendingRevocations,
      contains('ASC_API_PRIVATE_KEY_P8'),
    );
  });
}

Future<void> _supplyEvidence(ReleaseReadinessService service) async {
  service
    ..recordValidationEvidence('appleValidated', valid: true)
    ..recordValidationEvidence('googlePlayValidated', valid: true)
    ..recordValidationEvidence('firebaseValidated', valid: true)
    ..recordValidationEvidence('signingValidated', valid: true);
}

Map<String, Object?> _manifest(String secretPath) => {
  'schemaVersion': 1,
  'toolVersion': '1.0.0',
  'stage': 'DRAFT',
  'applicability': {
    'apple': 'required',
    'googlePlay': 'required',
    'firebase': 'required',
    'github': 'required',
  },
  'questionnaire': [
    for (final key in [
      'publisherLegalName',
      'supportEmail',
      'privacyPolicyUrl',
      'accountDeletionUrl',
      'monetization',
      'targetCountries',
      'apple.teamId',
      'apple.appStoreConnectAppRecordId',
      'apple.sku',
      'apple.apiKeyId',
      'apple.issuerId',
      'googlePlay.developerId',
      'googlePlay.appRecordCreated',
      'googlePlay.playDeveloperApiEnabled',
      'github.repository',
      'github.internalEnvironment',
      'github.productionEnvironment',
    ])
      {
        'key': key,
        'prompt': key,
        'type': key.endsWith('Created') || key.endsWith('Enabled')
            ? 'bool'
            : key == 'targetCountries'
            ? 'list'
            : 'string',
        'required': true,
      },
    for (final key in [
      'appleApiKey',
      'iosDistributionCertificate',
      'iosDistributionCertificatePassword',
      'iosProvisioningProfile',
      'androidUploadKeystore',
      'androidKeystorePassword',
      'androidKeyPassword',
    ])
      {
        'key': 'secret.$key',
        'prompt': key,
        'type': 'secretReference',
        'required': true,
      },
  ],
  'requiredEvidence': [
    'appleValidated',
    'googlePlayValidated',
    'firebaseValidated',
    'signingValidated',
  ],
  'answers': {
    'publisherLegalName': 'Publisher',
    'supportEmail': 'support@example.test',
    'privacyPolicyUrl': 'https://example.test/privacy',
    'accountDeletionUrl': 'https://example.test/delete',
    'monetization': 'free',
    'targetCountries': ['US'],
    'apple': {
      'teamId': 'TEAM123456',
      'appStoreConnectAppRecordId': '123456789',
      'sku': 'starter-sku',
      'apiKeyId': 'KEY1234567',
      'issuerId': 'issuer-id',
    },
    'googlePlay': {
      'developerId': 'developer-id',
      'appRecordCreated': true,
      'playDeveloperApiEnabled': true,
    },
    'github': {
      'repository': 'owner/repository',
      'internalEnvironment': 'release-internal',
      'productionEnvironment': 'release-production',
    },
  },
  'secretReferences': {
    'appleApiKey': 'file://$secretPath',
    'iosDistributionCertificate': 'file://$secretPath',
    'iosDistributionCertificatePassword': 'keychain://starter/ios-certificate',
    'iosProvisioningProfile': 'file://$secretPath',
    'androidUploadKeystore': 'file://$secretPath',
    'androidKeystorePassword': 'keychain://starter/android-store',
    'androidKeyPassword': 'keychain://starter/android-key',
  },
  'evidence': <String, Object?>{},
  'approval': null,
};

final class FakeCommandRunner implements CommandRunner {
  final List<String> calls = [];
  final List<String> standardInputs = [];
  bool protectedEnvironments = true;

  @override
  Future<CommandResult> run(
    String executable,
    List<String> arguments, {
    String? stdin,
  }) async {
    calls.add('$executable ${arguments.join(' ')}');
    if (stdin != null && arguments.contains('secret')) {
      standardInputs.add(stdin);
    }
    if (arguments.take(2).join(' ') == 'auth status') {
      return const CommandResult(0, '', '');
    }
    if (arguments.take(2).join(' ') == 'repo view') {
      return const CommandResult(0, 'owner/repository\n', '');
    }
    if (arguments.firstOrNull == 'api' && !arguments.contains('--method')) {
      if (!protectedEnvironments) {
        return const CommandResult(
          0,
          '{"protection_rules":[],"deployment_branch_policy":null}',
          '',
        );
      }
      return const CommandResult(
        0,
        '{"protection_rules":[{"type":"required_reviewers"}],'
            '"deployment_branch_policy":{"protected_branches":true}}',
        '',
      );
    }
    return const CommandResult(0, '', '');
  }
}
