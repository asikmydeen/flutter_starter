import 'dart:io';

import 'src/release_readiness/cli.dart';

Future<void> main(List<String> arguments) async {
  exitCode = await runReleaseReadiness(arguments);
}
