import 'dart:io';

enum SearchBackends {
  ripgrep,
  fdfind;

  bool get isInstalled => switch (this) {
    SearchBackends.ripgrep =>
      Process.runSync("rg", ["--version"]).exitCode == 0,
    SearchBackends.fdfind => Process.runSync("fd", ["--version"]).exitCode == 0,
  };

  String buildCommand({
    required String query,
    required String baseDir,
    required int limit,
  }) => switch (this) {
    SearchBackends.ripgrep => "rg -l '$query' $baseDir | head -n $limit",
    SearchBackends.fdfind => "fd '$query' $baseDir | head -n $limit",
  };
}
