import 'package:injectable/injectable.dart';
import 'dart:io';

@injectable
class FileSystemService {
  Future<List<FileSystemEntity>> getDirContent(String searchDir) async {
    await Future.delayed(const Duration(seconds: 1));
    final dir = Directory(searchDir);
    final items = await dir.list().toList();
    return items..sort(
      (a, b) => a.runtimeType.toString().compareTo(b.runtimeType.toString()),
    );
  }
}
