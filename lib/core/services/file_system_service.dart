import 'package:injectable/injectable.dart';
import 'dart:io';

@injectable
class FileSystemService {
  String get homeDir => switch (Platform.operatingSystem) {
    'windows' => Platform.environment['USERPROFILE']!,
    'macos' => Platform.environment['HOME']!,
    'linux' => Platform.environment['HOME']!,
    _ => throw UnsupportedError('Unsupported platform'),
  };

  bool isRoot(String dir) {
    final absolute = Directory(dir).absolute;
    return absolute.parent.path == absolute.path;
  }

  Future<List<FileSystemEntity>> getDirContent(String searchDir) async {
    await Future.delayed(const Duration(seconds: 1));
    final dir = Directory(searchDir);
    final items = await dir.list().toList();
    return items..sort(
      (a, b) => a.runtimeType.toString().compareTo(b.runtimeType.toString()),
    );
  }
}
