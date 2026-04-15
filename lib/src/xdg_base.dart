import 'dart:io' show Directory, Platform;
import 'package:path/path.dart' as path;

enum XDGDir {
  dataHome,
  configHome,
  stateHome,
  cacheHome,
  runtimeDir,
  configDirs,
  dataDirs;

  String getEnvName() {
    return switch (this) {
      XDGDir.dataHome => "XDG_DATA_HOME",
      XDGDir.configHome => "XDG_CONFIG_HOME",
      XDGDir.stateHome => "XDG_STATE_HOME",
      XDGDir.cacheHome => "XDG_CACHE_HOME",
      XDGDir.runtimeDir => "XDG_RUNTIME_DIR",
      XDGDir.dataDirs => "XDG_DATA_DIRS",
      XDGDir.configDirs => "XDG_CONFIG_DIRS",
    };
  }

  String _getDefault() {
    return switch (this) {
      XDGDir.dataHome => ".local/share",
      XDGDir.configHome => ".config",
      XDGDir.stateHome => ".local/state",
      XDGDir.cacheHome => ".cache",
      // fallback to a similar directory according to my limited knowledge
      XDGDir.runtimeDir => "/tmp",
      XDGDir.dataDirs => throw ArgumentError("dataDirs has no default value in the spec"),
      XDGDir.configDirs => throw ArgumentError("configDirs has no default value in the spec"),
    };
  }
}

Directory _getHomeSubdirectory(String subdir) {
  assert(subdir.isNotEmpty);
  final String homeDir = _home();
  return Directory(path.joinAll(<String>[homeDir, subdir]));
}

String _home() {
  assert(Platform.isLinux, "this package is linux only");

  final home = Platform.environment["HOME"];
  if (home == null) {
    throw StateError("HOME variable not found and is required for xdg to work");
  }
  if (home.isEmpty) {
    throw StateError("invalid HOME variable. Is empty");
  }
  return home;
}

Directory get home {
  return Directory(_home());
}

Directory? _directoryFromEnv(String env) {
  final String? value = Platform.environment[env];
  if (value != null) {
    return Directory(value);
  } else {
    return null;
  }
}

Directory _getDir(XDGDir xdg) {
  return _directoryFromEnv(xdg.getEnvName()) ?? _getHomeSubdirectory(xdg._getDefault());
}

Directory get dataHome => _getDir(XDGDir.dataHome);
Directory get configHome => _getDir(XDGDir.configHome);
Directory get stateHome => _getDir(XDGDir.stateHome);
Directory get runtimeDir => _getDir(XDGDir.runtimeDir);
List<Directory> get dataDirs => XDGDir.dataDirs.getEnvName().split(":").map(Directory.new).toList();
List<Directory> get configDirs => XDGDir.configDirs.getEnvName().split(":").map(Directory.new).toList();
