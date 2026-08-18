import 'dart:convert';
import 'dart:io';

/// Redacted command result.
final class CommandResult {
  const CommandResult(this.exitCode, this.stdout, this.stderr);

  final int exitCode;
  final String stdout;
  final String stderr;
}

/// Injectable process boundary used by GitHub and keychain adapters.
// An interface keeps tests from spawning local commands or receiving secrets.
// ignore: one_member_abstracts
abstract interface class CommandRunner {
  Future<CommandResult> run(
    String executable,
    List<String> arguments, {
    String? stdin,
  });
}

/// Real process runner. Sensitive values must be supplied through [stdin].
final class SystemCommandRunner implements CommandRunner {
  const SystemCommandRunner();

  @override
  Future<CommandResult> run(
    String executable,
    List<String> arguments, {
    String? stdin,
  }) async {
    final process = await Process.start(executable, arguments);
    if (stdin != null) process.stdin.write(stdin);
    await process.stdin.close();
    final output = await utf8.decodeStream(process.stdout);
    final error = await utf8.decodeStream(process.stderr);
    return CommandResult(await process.exitCode, output, error);
  }
}
