enum SearchBackends {
  ripgrep,
  fdfind;

  String buildCommand({required String query, required String baseDir}) =>
      switch (this) {
        SearchBackends.ripgrep => "rg -l '$query' $baseDir",
        SearchBackends.fdfind => "fd '$query' $baseDir",
      };
}
