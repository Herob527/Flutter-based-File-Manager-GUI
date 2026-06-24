import 'dart:io';

enum SearchBackends {
  ripgrep,
  fdfind,
  find;

  bool get isInstalled => switch (this) {
    .ripgrep => Process.runSync("rg", ["--version"]).exitCode == 0,
    .fdfind => Process.runSync("fd", ["--version"]).exitCode == 0,
    .find => true,
  };

  String buildCommand({
    required String query,
    required String baseDir,
    required int limit,
  }) => switch (this) {
    .ripgrep => "rg -l '$query' $baseDir | head -n $limit",
    .fdfind => "fd '$query' $baseDir | head -n $limit",
    .find => "find $baseDir -name '$query' | head -n $limit",
  };
}
