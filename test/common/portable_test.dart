@TestOn('windows')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:shared_preferences_windows/shared_preferences_windows.dart';

import 'package:fl_clash/common/portable.dart';

void main() {
  test('application support path is relative to the executable', () async {
    final tempDir = await Directory.systemTemp.createTemp('fl_clash_portable');
    addTearDown(() => tempDir.delete(recursive: true));

    final provider = PortablePathProviderWindows(
      executablePath: p.join(tempDir.path, 'FlClash.exe'),
    );

    final supportPath = await provider.getApplicationSupportPath();

    expect(supportPath, p.join(tempDir.path, 'config'));
    expect(Directory(supportPath!).existsSync(), isTrue);
  });

  test('setupPortableStorage installs portable implementations', () {
    setupPortableStorage();

    expect(PathProviderPlatform.instance, isA<PortablePathProviderWindows>());
    expect(
      SharedPreferencesStorePlatform.instance,
      isA<PortableSharedPreferencesWindows>(),
    );
  });
}
