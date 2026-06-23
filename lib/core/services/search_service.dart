import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';

@injectable
class SearchService {
  Future<List<FileSystemEntity>> search(
    String query,
    String baseDir, {
    int limit = 10,
  }) async {
    var command =
        "rg -l '$query' ${baseDir.replaceAll("'", "'\\''")} | head -n $limit";
    var result = await Process.run('bash', ['-c', command]);

    var lines = (result.stdout as String)
        .split("\n")
        .where((line) => line.trim().isNotEmpty)
        .map(
          (path) => FileSystemEntity.isDirectorySync(path)
              ? Directory(path).absolute
              : File(path).absolute,
        )
        .toList();

    return lines;
  }
}
