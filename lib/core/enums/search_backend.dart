enum SearchBackends {
  ripgrep(name: "ripgrep", template: "rg '{query}' {baseDir}"),
  fdfind(name: "fdfind", template: "fd '{query}' {baseDir}");

  const SearchBackends({required this.template, required this.name});

  final String template;
  final String name;
}
