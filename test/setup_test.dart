import 'package:test/test.dart';

import '../setup.dart' as setup;

void main() {
  group('setup.dart', () {
    test('parses -v as verbose mode', () {
      final results = setup.createSetupArgParser().parse(['windows', '-v']);

      expect(results['verbose'], isTrue);
      expect(results.rest, ['windows']);
    });

    test('accepts dev application environment', () {
      final results = setup.createSetupArgParser().parse([
        'windows',
        '--env',
        'dev',
      ]);

      expect(results['env'], 'dev');
    });

    test('Flutter build environment does not depend on Core SHA256', () {
      expect(setup.createBuildEnvironment('dev'), {'APP_ENV': 'dev'});
    });

    test('omits verbose from flutter build args by default', () {
      final args = setup.createFlutterBuildArgs(verbose: false);

      expect(args, ['dart-define-from-file=env.json']);
    });

    test('adds verbose to flutter build args with -v', () {
      final args = setup.createFlutterBuildArgs(verbose: true);

      expect(args, ['verbose', 'dart-define-from-file=env.json']);
    });

    test('defaults package targets to portable zip', () {
      final results = setup.createSetupArgParser().parse([]);

      expect(results['targets'], 'zip');
    });
  });
}
