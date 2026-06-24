import 'dart:io';

T? safeExecute<T>(T Function() fn) {
  try {
    return fn();
  } on Exception catch (_) {
    return null;
  }
}

enum SearchBackends {
  ripgrep,
  fdfind,
  find;

  bool get isInstalled => switch (this) {
    .ripgrep => safeExecute(() => Process.runSync("rg", ["--version"])) != null,
    .fdfind => safeExecute(() => Process.runSync("fd", ["--version"])) != null,
    .find => true,
  };

  String buildCommand({
    required String query,
    required String baseDir,
    required int limit,
  }) => switch (this) {
    .ripgrep => "rg -l '$query' $baseDir | head -n $limit",
    .fdfind => "fd '$query' $baseDir | head -n $limit",
    .find =>
      Platform.isLinux
          ? "find $baseDir -name '$query' | head -n $limit"
          : "find '$query' $baseDir",
  };
}
