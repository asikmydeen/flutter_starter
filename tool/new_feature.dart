// Feature scaffolder. Stamps the canonical feature layout so every
// feature starts identical to the reference (`features/todos`).
//
// Usage:
//   dart run tool/new_feature.dart <snake_case_name>
//
// Generates:
//   lib/features/<name>/domain/<name>.dart              (freezed entity)
//   lib/features/<name>/domain/<name>_repository.dart    (interface)
//   lib/features/<name>/data/<name>_dto.dart             (DTO + json)
//   lib/features/<name>/data/api_<name>_repository.dart  (dio impl)
//   lib/features/<name>/application/<name>_controller.dart
//   lib/features/<name>/presentation/<name>_screen.dart
//   test/features/<name>/... (matching test skeletons)
//
// Generation is blocked until release readiness is READY.
// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

void main(List<String> args) {
  if (args.length != 1 || !RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(args[0])) {
    stderr.writeln('Usage: dart run tool/new_feature.dart <snake_case_name>');
    exit(64);
  }
  final snake = args[0];
  final pascal = snake
      .split('_')
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join();
  final camel = pascal[0].toLowerCase() + pascal.substring(1);

  final root =
      Platform.environment['FEATURE_GENERATOR_ROOT'] ??
      File(Platform.script.toFilePath()).parent.parent.path;
  final readinessFile = File('$root/.release-readiness/state.json');
  final readiness = readinessFile.existsSync()
      ? jsonDecode(readinessFile.readAsStringSync()) as Map<String, dynamic>
      : const <String, dynamic>{};
  if (readiness['stage'] != 'READY' ||
      readiness['approvedDigest'] == null ||
      readiness['approvedDigest'] != readiness['inputsDigest']) {
    stderr.writeln(
      'ERROR: project generation is blocked until release readiness is READY.',
    );
    exit(3);
  }
  final featureDir = '$root/lib/features/$snake';
  final routerFile = File('$root/lib/core/router/app_router.dart');
  final arbFile = File('$root/lib/l10n/arb/app_en.arb');
  if (!routerFile.existsSync() || !arbFile.existsSync()) {
    stderr.writeln('ERROR: router and English ARB files are required.');
    exit(1);
  }
  final routerBefore = routerFile.readAsStringSync();
  final arbBefore = arbFile.readAsStringSync();
  if (!routerBefore.contains('// feature-generator-imports') ||
      !routerBefore.contains('// feature-generator-route-names') ||
      !routerBefore.contains('// feature-generator-routes')) {
    stderr.writeln('ERROR: feature-generator router markers are missing.');
    exit(1);
  }
  final titleKey = '${camel}Title';
  final arb = jsonDecode(arbBefore)! as Map<String, dynamic>;
  if (arb.containsKey(titleKey)) {
    stderr.writeln('ERROR: localization key already exists: $titleKey');
    exit(1);
  }
  if (Directory(featureDir).existsSync()) {
    stderr.writeln('ERROR: $featureDir already exists.');
    exit(1);
  }

  final packageName = _readPackageName(root);
  final files =
      <String, String>{
        '$featureDir/domain/$snake.dart': _entity(snake, pascal),
        '$featureDir/domain/${snake}_repository.dart': _repoInterface(
          snake,
          pascal,
        ),
        '$featureDir/data/${snake}_dto.dart': _dto(snake, pascal),
        '$featureDir/data/api_${snake}_repository.dart': _repoImpl(
          snake,
          pascal,
        ),
        '$featureDir/application/${snake}_controller.dart': _controller(
          snake,
          pascal,
          camel,
        ),
        '$featureDir/presentation/${snake}_screen.dart': _screen(
          snake,
          pascal,
          camel,
        ),
        '$root/test/features/$snake/application/${snake}_controller_test.dart':
            _controllerTest(snake, pascal, camel),
        '$root/test/features/$snake/data/api_${snake}_repository_test.dart':
            _repositoryTest(snake, pascal),
        '$root/test/features/$snake/presentation/${snake}_screen_test.dart':
            _screenTest(snake, pascal, camel),
      }..updateAll(
        (path, content) => content.replaceAll(
          'package:flutter_starter/',
          'package:$packageName/',
        ),
      );

  final collisions = files.keys
      .where((path) => File(path).existsSync())
      .toList();
  if (collisions.isNotEmpty) {
    stderr.writeln('ERROR: generation would overwrite existing files:');
    collisions.forEach(stderr.writeln);
    exit(1);
  }

  try {
    for (final MapEntry(key: path, value: content) in files.entries) {
      File(path)
        ..createSync(recursive: true)
        ..writeAsStringSync(content);
      print('created ${path.replaceFirst('$root/', '')}');
    }

    _registerFeature(
      routerFile: routerFile,
      arbFile: arbFile,
      routerBefore: routerBefore,
      arb: arb,
      snake: snake,
      pascal: pascal,
      camel: camel,
    );

    final format = Process.runSync(Platform.resolvedExecutable, [
      'format',
      ...files.keys,
      routerFile.path,
    ]);
    if (format.exitCode != 0) {
      throw ProcessException(
        Platform.resolvedExecutable,
        ['format'],
        '${format.stderr}',
        format.exitCode,
      );
    }
  } on Exception catch (error) {
    for (final path in files.keys) {
      final file = File(path);
      if (file.existsSync()) file.deleteSync();
    }
    if (Directory(featureDir).existsSync()) {
      Directory(featureDir).deleteSync(recursive: true);
    }
    routerFile.writeAsStringSync(routerBefore);
    arbFile.writeAsStringSync(arbBefore);
    stderr.writeln('ERROR: generation rolled back: $error');
    exit(1);
  }

  print('''

Next steps (in order):
  1. fvm dart run build_runner build
  2. fvm flutter gen-l10n
  3. ./tool/verify.sh
''');
}

String _entity(String snake, String pascal) =>
    '''
import 'package:freezed_annotation/freezed_annotation.dart';

part '$snake.freezed.dart';

/// Domain entity. Pure data — no JSON, no framework imports.
@freezed
abstract class $pascal with _\$$pascal {
  /// Creates a $snake.
  const factory $pascal({
    required String id,
    required String name,
  }) = _$pascal;
}
''';

String _repoInterface(String snake, String pascal) =>
    '''
import 'package:flutter_starter/core/result/result.dart';
import 'package:flutter_starter/features/$snake/domain/$snake.dart';

/// Contract for fetching ${snake}s. Implementation: data/api_${snake}_repository.dart.
// ignore: one_member_abstracts - grows with the feature; interface is the point.
abstract interface class ${pascal}Repository {
  /// Never throws — failures come back as `Failure`.
  Future<Result<List<$pascal>>> fetch${pascal}s();
}
''';

String _dto(String snake, String pascal) =>
    '''
import 'package:flutter_starter/features/$snake/domain/$snake.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '${snake}_dto.freezed.dart';
part '${snake}_dto.g.dart';

/// Wire format — mirrors the API exactly, owns all JSON concerns.
@freezed
abstract class ${pascal}Dto with _\$${pascal}Dto {
  /// Creates a DTO from its fields.
  const factory ${pascal}Dto({
    required String id,
    required String name,
  }) = _${pascal}Dto;

  const ${pascal}Dto._();

  /// Parses the API JSON representation.
  factory ${pascal}Dto.fromJson(Map<String, dynamic> json) =>
      _\$${pascal}DtoFromJson(json);

  /// Converts this wire model into the domain entity.
  $pascal toDomain() => $pascal(id: id, name: name);
}
''';

String _repoImpl(String snake, String pascal) =>
    '''
import 'package:dio/dio.dart';
import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/core/result/result.dart';
import 'package:flutter_starter/features/$snake/data/${snake}_dto.dart';
import 'package:flutter_starter/features/$snake/domain/$snake.dart';
import 'package:flutter_starter/features/$snake/domain/${snake}_repository.dart';

/// HTTP implementation of [${pascal}Repository].
class Api${pascal}Repository implements ${pascal}Repository {
  /// Creates the repository with an injected HTTP client.
  const Api${pascal}Repository(this._dio);

  final Dio _dio;

  @override
  Future<Result<List<$pascal>>> fetch${pascal}s() async {
    try {
      final response = await _dio.get<List<dynamic>>('/v1/${snake}s');
      final data = response.data;
      if (data == null) {
        return const Failure(ParsingException());
      }
      final items = data
          .map((e) => ${pascal}Dto.fromJson(e as Map<String, dynamic>).toDomain())
          .toList();
      return Success(items);
      // JSON collection casts throw TypeError, which this repository maps.
      // ignore: avoid_catching_errors
    } on TypeError catch (e) {
      return Failure(mapToAppException(e));
    } on Exception catch (e) {
      return Failure(mapToAppException(e));
    }
  }
}
''';

String _controller(String snake, String pascal, String camel) =>
    '''
import 'package:flutter_starter/core/network/dio_client.dart';
import 'package:flutter_starter/core/result/result.dart';
import 'package:flutter_starter/features/$snake/data/api_${snake}_repository.dart';
import 'package:flutter_starter/features/$snake/domain/$snake.dart';
import 'package:flutter_starter/features/$snake/domain/${snake}_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '${snake}_controller.g.dart';

/// Binds the interface to the HTTP implementation. Override in tests.
@riverpod
${pascal}Repository ${camel}Repository(Ref ref) =>
    Api${pascal}Repository(ref.watch(dioProvider));

/// Async controller for the $snake feature.
@riverpod
class ${pascal}Controller extends _\$${pascal}Controller {
  @override
  Future<List<$pascal>> build() async {
    final result = await ref.watch(${camel}RepositoryProvider).fetch${pascal}s();
    return result.valueOrThrow;
  }

  /// Re-fetches, moving through loading → data/error.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(${camel}RepositoryProvider).fetch${pascal}s();
      return result.valueOrThrow;
    });
  }
}
''';

String _screen(String snake, String pascal, String camel) =>
    '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/features/$snake/application/${snake}_controller.dart';
import 'package:flutter_starter/l10n/app_exception_localization.dart';
import 'package:flutter_starter/l10n/gen/app_localizations.dart';

/// Screen for the $snake feature. Renders every AsyncValue state.
class ${pascal}Screen extends ConsumerWidget {
  /// Creates the $snake screen.
  const ${pascal}Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(${camel}ControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).${camel}Title)),
      body: switch (items) {
        AsyncData(:final value) => ListView.builder(
            itemCount: value.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(value[index].name),
            ),
          ),
        AsyncError(:final error) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  error is AppException
                      ? localizeAppException(AppLocalizations.of(context), error)
                      : AppLocalizations.of(context).unknownError,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.read(${camel}ControllerProvider.notifier).refresh(),
                  child: Text(AppLocalizations.of(context).retryButton),
                ),
              ],
            ),
          ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
''';

String _controllerTest(String snake, String pascal, String camel) =>
    '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/core/result/result.dart';
import 'package:flutter_starter/features/$snake/application/${snake}_controller.dart';
import 'package:flutter_starter/features/$snake/domain/$snake.dart';
import 'package:flutter_starter/features/$snake/domain/${snake}_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class Mock${pascal}Repository extends Mock implements ${pascal}Repository {}

void main() {
  group('${pascal}Controller', () {
    late Mock${pascal}Repository repository;
    late ProviderContainer container;

    setUp(() {
      repository = Mock${pascal}Repository();
      container = ProviderContainer(
        overrides: [${camel}RepositoryProvider.overrideWithValue(repository)],
        retry: (_, _) => null, // determinism: no auto-retry in tests
      );
      addTearDown(container.dispose);
    });

    /// Call AFTER stubbing — listening triggers the first build, and
    /// autoDispose providers need a listener to survive loading.
    void subscribe() =>
        container.listen(${camel}ControllerProvider, (_, _) {});

    test('should expose items when the repository succeeds', () async {
      const items = [$pascal(id: 'id-1', name: 'Example')];
      when(
        repository.fetch${pascal}s,
      ).thenAnswer((_) async => const Success(items));
      subscribe();

      final result = await container.read(${camel}ControllerProvider.future);

      expect(result, items);
    });

    test('should expose AsyncError when the repository fails', () async {
      when(
        repository.fetch${pascal}s,
      ).thenAnswer((_) async => const Failure(NetworkException()));
      subscribe();

      await expectLater(
        container.read(${camel}ControllerProvider.future),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
''';

String _repositoryTest(String snake, String pascal) =>
    '''
import 'package:dio/dio.dart';
import 'package:flutter_starter/core/result/result.dart';
import 'package:flutter_starter/features/$snake/data/api_${snake}_repository.dart';
import 'package:flutter_starter/features/$snake/domain/$snake.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  test('should parse ${snake}s from the API', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
    final adapter = DioAdapter(dio: dio)
      ..onGet(
        '/v1/${snake}s',
        (server) => server.reply(200, [
          {'id': 'id-1', 'name': 'Example'},
        ]),
      );
    final repository = Api${pascal}Repository(dio);

    final result = await repository.fetch${pascal}s();

    expect(result, isA<Success<List<$pascal>>>());
    expect((result as Success<List<$pascal>>).value.single.name, 'Example');
    expect(adapter, isNotNull);
  });
}
''';

String _screenTest(String snake, String pascal, String camel) =>
    '''
import 'package:flutter_starter/core/result/result.dart';
import 'package:flutter_starter/features/$snake/application/${snake}_controller.dart';
import 'package:flutter_starter/features/$snake/domain/$snake.dart';
import 'package:flutter_starter/features/$snake/domain/${snake}_repository.dart';
import 'package:flutter_starter/features/$snake/presentation/${snake}_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

class Mock${pascal}Repository extends Mock implements ${pascal}Repository {}

void main() {
  testWidgets('should render fetched ${snake}s', (tester) async {
    final repository = Mock${pascal}Repository();
    when(repository.fetch${pascal}s).thenAnswer(
      (_) async => const Success([$pascal(id: 'id-1', name: 'Example')]),
    );

    await tester.pumpApp(
      const ${pascal}Screen(),
      overrides: [${camel}RepositoryProvider.overrideWithValue(repository)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Example'), findsOneWidget);
  });
}
''';

void _registerFeature({
  required File routerFile,
  required File arbFile,
  required String routerBefore,
  required Map<String, dynamic> arb,
  required String snake,
  required String pascal,
  required String camel,
}) {
  final routePath = snake.replaceAll('_', '-');
  final router = routerBefore
      .replaceFirst(
        '// feature-generator-imports',
        "import 'package:flutter_starter/features/$snake/presentation/"
            "${snake}_screen.dart';\n// feature-generator-imports",
      )
      .replaceFirst(
        '  // feature-generator-route-names',
        "  static const $camel = '$camel';\n"
            '  // feature-generator-route-names',
      )
      .replaceFirst(
        '          // feature-generator-routes',
        '''
          GoRoute(
            path: '$routePath',
            name: RouteNames.$camel,
            builder: (context, state) => const ${pascal}Screen(),
          ),
          // feature-generator-routes''',
      );
  routerFile.writeAsStringSync(router);

  final titleKey = '${camel}Title';
  arb
    ..[titleKey] = pascal
    ..['@$titleKey'] = {
      'description': 'App bar title for the generated $snake feature',
    };
  arbFile.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(arb)}\n',
  );
}

String _readPackageName(String root) {
  final manifest = File('$root/starter.yaml');
  if (!manifest.existsSync()) return 'flutter_starter';
  final yaml = loadYaml(manifest.readAsStringSync());
  if (yaml is! YamlMap || yaml['project'] is! YamlMap) {
    throw const FormatException(
      'starter.yaml project configuration is invalid',
    );
  }
  final name = (yaml['project']! as YamlMap)['packageName'];
  if (name is! String || !RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name)) {
    throw const FormatException('starter.yaml packageName is invalid');
  }
  return name;
}
