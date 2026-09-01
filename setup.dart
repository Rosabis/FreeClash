import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;

const defaultTargets = 'zip';

Future<void> main(List<String> args) async {
  final parser = createSetupArgParser();

  if (args.contains('--help') || args.contains('-h')) {
    _showHelp(parser);
    exit(0);
  }

  final results = parser.parse(args);
  final rest = results.rest;
  if (rest.isNotEmpty && rest.first != 'windows') {
    stderr.writeln('Unsupported platform: ${rest.first}. Windows only.');
    _showHelp(parser);
    exit(1);
  }

  if (!Platform.isWindows) {
    stderr.writeln(
      'Unsupported host platform: ${Platform.operatingSystem}. Windows only.',
    );
    exit(1);
  }

  final env = results['env'] as String;
  final rootDir = Directory.current.path;
  final arch = _detectArch();
  final targets = results['targets'] as String;
  final verbose = results['verbose'] as bool;

  final exitCode = await _package(
    env,
    targets,
    rootDir,
    arch,
    verbose: verbose,
  );
  exit(exitCode);
}

ArgParser createSetupArgParser() {
  return ArgParser()
    ..addOption(
      'env',
      defaultsTo: 'pre',
      allowed: ['dev', 'pre', 'stable'],
      help: 'Application environment',
    )
    ..addOption(
      'targets',
      defaultsTo: defaultTargets,
      valueHelp: 'zip',
      help: 'Package targets (default: zip)',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Enable verbose Flutter build output',
    );
}

List<String> createFlutterBuildArgs({required bool verbose}) {
  return [
    if (verbose) 'verbose',
    'dart-define-from-file=env.json',
  ];
}

Map<String, String> createBuildEnvironment(String env) {
  return {'APP_ENV': env};
}

void _showHelp(ArgParser parser) {
  stderr.writeln('Usage: dart setup.dart [windows] [options]');
  stderr.writeln();
  stderr.writeln(parser.usage);
}

Future<int> _package(
  String env,
  String targets,
  String rootDir,
  String arch, {
  required bool verbose,
}) async {
  final file = File(p.join(rootDir, 'env.json'));
  await file.writeAsString(jsonEncode(createBuildEnvironment(env)));

  final flutterBuildArgs = createFlutterBuildArgs(verbose: verbose);

  final activateResult = await Process.run('dart', [
    'pub',
    'global',
    'activate',
    '-s',
    'git',
    'https://github.com/chen08209/flutter_distributor.git',
    '--git-ref',
    'FlClash',
    '--git-path',
    'packages/flutter_distributor',
  ]);
  if (activateResult.exitCode != 0) {
    stderr.write(activateResult.stderr);
    return activateResult.exitCode;
  }

  final process = await Process.start(
    'flutter_distributor',
    [
      'package',
      '--skip-clean',
      '--platform',
      'windows',
      '--targets',
      targets,
      if (flutterBuildArgs.isNotEmpty)
        '--flutter-build-args=${flutterBuildArgs.join(',')}',
      '--description',
      arch,
    ],
    includeParentEnvironment: true,
    runInShell: true,
  );

  process.stdout.listen((data) {
    stdout.write(utf8.decode(data));
  });
  process.stderr.listen((data) {
    stderr.write(utf8.decode(data));
  });
  final exitCode = await process.exitCode;
  return exitCode;
}

String _detectArch() {
  final pa = Platform.environment['PROCESSOR_ARCHITECTURE'] ?? 'AMD64';
  return pa.toUpperCase() == 'ARM64' ? 'arm64' : 'amd64';
}
