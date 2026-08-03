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
// After generating: run codegen, add a route in core/router/app_router.dart,
// replace the TODO(agent) markers, then ./tool/verify.sh.
// ignore_for_file: avoid_print
import 'dart:io';

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

  final root = File(Platform.script.toFilePath()).parent.parent.path;
  final featureDir = '$root/lib/features/$snake';
  if (Directory(featureDir).existsSync()) {
    stderr.writeln('ERROR: $featureDir already exists.');
    exit(1);
  }

  final files = <String, String>{
    '$featureDir/domain/$snake.dart': _entity(snake, pascal),
    '$featureDir/domain/${snake}_repository.dart': _repoInterface(
      snake,
      pascal,
    ),
    '$featureDir/data/${snake}_dto.dart': _dto(snake, pascal),
    '$featureDir/data/api_${snake}_repository.dart': _repoImpl(snake, pascal),
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
  };

  for (final MapEntry(key: path, value: content) in files.entries) {
    File(path)
      ..createSync(recursive: true)
      ..writeAsStringSync(content);
    print('created ${path.replaceFirst('$root/', '')}');
  }

  // Format generated files so they pass lints out of the box.
  Process.runSync('dart', ['format', ...files.keys]);

  print('''

Next steps (in order):
  1. Replace every TODO(agent) marker with real fields/logic.
  2. dart run build_runner build --delete-conflicting-outputs
  3. Add a route in lib/core/router/app_router.dart (RouteNames + GoRoute).
  4. Add user-facing strings to lib/l10n/arb/app_en.arb, run: flutter gen-l10n
  5. ./tool/verify.sh
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
    required int id,
    // TODO(agent): add fields.
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
    required int id,
    // TODO(agent): mirror the API fields.
  }) = _${pascal}Dto;

  const ${pascal}Dto._();

  /// Parses the API JSON representation.
  factory ${pascal}Dto.fromJson(Map<String, dynamic> json) =>
      _\$${pascal}DtoFromJson(json);

  /// Converts this wire model into the domain entity.
  $pascal toDomain() => $pascal(id: id);
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
      // TODO(agent): set the real endpoint path.
      final response = await _dio.get<List<dynamic>>('/${snake}s');
      final data = response.data;
      if (data == null) {
        return const Failure(ParsingException());
      }
      final items = data
          .map((e) => ${pascal}Dto.fromJson(e as Map<String, dynamic>).toDomain())
          .toList();
      return Success(items);
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

/// Screen for the $snake feature. Renders every AsyncValue state.
class ${pascal}Screen extends ConsumerWidget {
  /// Creates the $snake screen.
  const ${pascal}Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(${camel}ControllerProvider);

    return Scaffold(
      // TODO(agent): move strings to lib/l10n/arb/app_en.arb.
      appBar: AppBar(title: const Text('$pascal')),
      body: switch (items) {
        AsyncData(:final value) => ListView.builder(
            itemCount: value.length,
            itemBuilder: (context, index) => ListTile(
              // TODO(agent): render the entity.
              title: Text('\${value[index].id}'),
            ),
          ),
        AsyncError(:final error) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  error is AppException ? error.message : '\$error',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.read(${camel}ControllerProvider.notifier).refresh(),
                  child: const Text('Retry'),
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
      // TODO(agent): build a realistic fixture.
      const items = [$pascal(id: 1)];
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
