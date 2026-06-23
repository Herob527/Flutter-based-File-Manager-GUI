import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

const DEFAULT_LIMIT = 10;

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
    int limit = DEFAULT_LIMIT,
  }) async {
    try {
      cancelCurrentSearch();

      var command =
          "rg -l '$query' ${baseDir.replaceAll("'", "'\\''")} | head -n $limit";
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
