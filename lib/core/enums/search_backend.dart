enum SearchBackends {
  ripgrep(
    name: "ripgrep",
    description: "Search files containing given pattern",
    template: "rg -l '{query}' {baseDir}",
  ),
  fdfind(
    name: "fdfind",
    description: "Find files according to given pattern",
    template: "fd '{query}' {baseDir}",
  );

  const SearchBackends({
    required this.name,
    required this.description,
    required this.template,
  });

  final String template;
  final String name;
  final String description;
}
