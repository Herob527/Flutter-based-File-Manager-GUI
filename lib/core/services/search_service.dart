import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

const defaultLimit = 10;

enum SearchBackends {
  ripgrep(template: "rg {query} {baseDir}"),
  fdfind(template: "fd {query} {baseDir}");

  const SearchBackends({required this.template});

  final String template;
}

@injectable
class SearchService {
  Process? _currentProcess;

  void cancelCurrentSearch() {
    _currentProcess?.kill();
    _currentProcess = null;
  }

  Future<List<FileSystemEntity>> search(
    String query,
    String baseDir, {
    int limit = defaultLimit,
    SearchBackends backend = SearchBackends.ripgrep,
  }) async {
    try {
      cancelCurrentSearch();

      var command = backend.template
          .replaceAll("{query}", query)
          .replaceAll("{baseDir}", baseDir);

      _currentProcess = await Process.start('bash', ['-c', command]);
      var result = await _currentProcess!.stdout.transform(utf8.decoder).join();
      await _currentProcess!.stderr.drain();
      await _currentProcess!.exitCode;
      _currentProcess = null;

      var lines = result
          .split("\n")
          .where((line) => line.trim().isNotEmpty)
          .map(
            (path) => FileSystemEntity.isDirectorySync(path)
                ? Directory(path).absolute
                : File(path).absolute,
          )
          .toList();

      return lines;
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
      _currentProcess = null;
      return [];
    }
  }
}
