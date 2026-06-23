enum SearchBackends {
  ripgrep,
  fdfind;

  String buildCommand({
    required String query,
    required String baseDir,
    required int limit,
  }) => switch (this) {
    SearchBackends.ripgrep => "rg -l '$query' $baseDir | head -n $limit",
    SearchBackends.fdfind => "fd '$query' $baseDir | head -n $limit",
  };
}
