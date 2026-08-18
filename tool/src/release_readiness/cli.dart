import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

import 'command_runner.dart';
import 'github_client.dart';
import 'model.dart';
import 'service.dart';
import 'state_store.dart';

/// Runs the release-readiness command and returns a process exit code.
Future<int> runReleaseReadiness(
  List<String> arguments, {
  Directory? repositoryRoot,
  CommandRunner runner = const SystemCommandRunner(),
  IOSink? stdoutSink,
  IOSink? stderrSink,
}) async {
  final out = stdoutSink ?? stdout;
  final err = stderrSink ?? stderr;
  final parser = _parser();
  ArgResults results;
  try {
    results = parser.parse(arguments);
  } on FormatException catch (error) {
    err
      ..writeln(error.message)
      ..writeln(parser.usage);
    return 64;
  }
  final command = results.command;
  if (command == null) {
    out.writeln(parser.usage);
    return 64;
  }
  final root = repositoryRoot ?? _findRepositoryRoot();
  final manifest =
      jsonDecode(
            File(
              '${root.path}/config/release_readiness.json',
            ).readAsStringSync(),
          )!
          as Map<String, Object?>;
  final answers = manifest['answers']! as Map<String, Object?>;
  final githubAnswers = answers['github']! as Map<String, Object?>;
  final github = GithubClient(
    repository: githubAnswers['repository']! as String,
    runner: runner,
  );
  final service = ReleaseReadinessService(
    repositoryRoot: root,
    store: ReadinessStateStore(
      File('${root.path}/.release-readiness/state.json'),
    ),
    github: github,
  );

  try {
    switch (command.name) {
      case 'init':
        var state = service.initialize();
        if (command['non-interactive'] != true) {
          if (!stdin.hasTerminal) {
            err.writeln(
              'Interactive input is unavailable. Re-run in a terminal or use '
              '--non-interactive and answer commands.',
            );
            return 2;
          }
          state = _runQuestionnaire(service, out);
        }
        _printState(out, state);
      case 'status':
        _printState(out, service.status());
      case 'answer':
        final key = command['key']! as String;
        final rawValue = command['value']! as String;
        _printState(out, service.answer(key, _parseValue(rawValue)));
      case 'validate':
        _printState(
          out,
          await service.validate(live: command['live']! as bool),
        );
      case 'resume':
        if (command['interactive'] == true) {
          if (!stdin.hasTerminal) {
            err.writeln('Interactive input is unavailable.');
            return 2;
          }
          _runQuestionnaire(service, out);
        }
        _printState(
          out,
          await service.validate(live: command['live']! as bool),
        );
      case 'plan':
        final outcome = await service.configureGithub(confirm: false);
        outcome.plan.forEach(out.writeln);
      case 'configure-github':
        if (command['confirm'] != true) {
          err.writeln(
            'Refusing remote mutation without --confirm. Run plan first.',
          );
          return 64;
        }
        _printState(
          out,
          (await service.configureGithub(confirm: true)).state,
        );
      case 'approve':
        _printState(out, service.approve());
      case 'rotate':
        final outcome = await service.rotate(
          name: command['name']! as String,
          environment: command['environment']! as String,
          replacementReference: command['replacement-ref']! as String,
          confirm: command['confirm']! as bool,
        );
        if (outcome.plan.isNotEmpty) {
          outcome.plan.forEach(out.writeln);
        } else {
          _printState(out, outcome.state);
        }
      default:
        err.writeln('Unknown command: ${command.name}');
        return 64;
    }
  } on FileSystemException catch (error) {
    err.writeln('Readiness filesystem error: ${error.message}');
    return 5;
  } on FormatException catch (error) {
    err.writeln('Readiness configuration error: ${error.message}');
    return 2;
    // Readiness state errors are expected CLI validation failures.
    // ignore: avoid_catching_errors
  } on StateError catch (error) {
    err.writeln(error.message);
    return 5;
    // Invalid user-provided values are converted to a stable CLI exit code.
    // ignore: avoid_catching_errors
  } on ArgumentError catch (error) {
    err.writeln(error.message);
    return 2;
  }
  return 0;
}

ArgParser _parser() => ArgParser()
  ..addCommand(
    'init',
    ArgParser()..addFlag('non-interactive', negatable: false),
  )
  ..addCommand('status')
  ..addCommand(
    'answer',
    ArgParser()
      ..addOption('key', mandatory: true)
      ..addOption('value', mandatory: true),
  )
  ..addCommand('validate', ArgParser()..addFlag('live', negatable: false))
  ..addCommand(
    'resume',
    ArgParser()
      ..addFlag('live', negatable: false)
      ..addFlag('interactive', negatable: false),
  )
  ..addCommand('plan')
  ..addCommand(
    'configure-github',
    ArgParser()..addFlag('confirm', negatable: false),
  )
  ..addCommand('approve')
  ..addCommand(
    'rotate',
    ArgParser()
      ..addOption('name', mandatory: true)
      ..addOption('environment', mandatory: true)
      ..addOption('replacement-ref', mandatory: true)
      ..addFlag('confirm', negatable: false),
  );

Object? _parseValue(String raw) {
  try {
    return jsonDecode(raw);
  } on FormatException {
    return raw;
  }
}

ReadinessState _runQuestionnaire(
  ReleaseReadinessService service,
  IOSink output,
) {
  var state = service.status();
  for (final question in service.questionnaire) {
    final key = question['key']! as String;
    if (state.answers.containsKey(key)) continue;
    final prompt = question['prompt']! as String;
    final type = question['type']! as String;
    final required = question['required']! as bool;
    while (true) {
      output.write('$prompt${required ? ' [required]' : ''}: ');
      final raw = stdin.readLineSync()?.trim();
      if (raw == null) throw const FormatException('Input stream closed');
      if (raw.isEmpty && required) {
        output.writeln('A value or explicit notApplicable answer is required.');
        continue;
      }
      final value = _parseQuestionValue(raw, type);
      state = service.answer(key, value);
      break;
    }
  }
  return state;
}

Object? _parseQuestionValue(String raw, String type) => switch (type) {
  'bool' => switch (raw.toLowerCase()) {
    'true' || 'yes' || 'y' => true,
    'false' || 'no' || 'n' => false,
    _ => throw const FormatException('Enter yes or no'),
  },
  'list' =>
    raw.startsWith('[')
        ? (jsonDecode(raw)! as List<Object?>)
        : raw.split(',').map((item) => item.trim()).toList(),
  'secretReference' => raw,
  _ => raw,
};

void _printState(IOSink sink, ReadinessState state) {
  sink.writeln(const JsonEncoder.withIndent('  ').convert(state.toJson()));
}

Directory _findRepositoryRoot() {
  var directory = File(Platform.script.toFilePath()).parent;
  while (!File('${directory.path}/pubspec.yaml').existsSync()) {
    final parent = directory.parent;
    if (parent.path == directory.path) {
      throw StateError('Unable to find repository root');
    }
    directory = parent;
  }
  return directory;
}
