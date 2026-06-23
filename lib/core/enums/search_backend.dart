enum SearchBackends {
  ripgrep(
    name: "ripgrep",
    description: "Search files containing given pattern",
  ),
  fdfind(name: "fdfind", description: "Find files according to given pattern");

  const SearchBackends({required this.name, required this.description});

  final String name;
  final String description;

  String buildCommand({required String query, required String baseDir}) =>
      switch (this) {
        SearchBackends.ripgrep => "rg -l '$query' $baseDir",
        SearchBackends.fdfind => "fd '$query' $baseDir",
      };
}
