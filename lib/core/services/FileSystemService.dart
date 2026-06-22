import 'package:injectable/injectable.dart';
import 'dart:io';

@injectable
class FileSystemService {
  Future<List<FileSystemEntity>> getDirContent() async {
    final homeDir = Platform.environment['HOME'];
    if (homeDir == null) {
      throw Exception('HOME environment variable is not set');
    }
    await Future.delayed(const Duration(seconds: 1));
    final dir = Directory(homeDir);
    final items = await dir.list().toList();
    return items..sort(
      (a, b) => a.runtimeType.toString().compareTo(b.runtimeType.toString()),
    );
  }
}
