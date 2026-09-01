import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:path_provider_windows/path_provider_windows.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:shared_preferences_windows/shared_preferences_windows.dart';

const portableDataDirectoryName = 'config';

class PortablePathProviderWindows extends PathProviderWindows {
  PortablePathProviderWindows({String? executablePath})
      : executablePath = executablePath ?? Platform.resolvedExecutable;

  final String executablePath;

  @override
  Future<String?> getApplicationSupportPath() async {
    final directory = Directory(
      join(dirname(executablePath), portableDataDirectoryName),
    );
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    return directory.path;
  }
}

class PortableSharedPreferencesWindows extends SharedPreferencesWindows {
  PortableSharedPreferencesWindows(this._pathProvider);

  final PathProviderWindows _pathProvider;

  @override
  PathProviderWindows get pathProvider => _pathProvider;
}

void setupPortableStorage() {
  final provider = PortablePathProviderWindows();
  PathProviderPlatform.instance = provider;
  SharedPreferencesStorePlatform.instance =
      PortableSharedPreferencesWindows(provider);
}

