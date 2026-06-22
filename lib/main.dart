import 'dart:io';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<FileSystemEntity>> getDirContent() async {
    final homeDir = Platform.environment['HOME'];
    if (homeDir == null) {
      throw Exception('HOME environment variable is not set');
    }
    await Future.delayed(const Duration(seconds: 1));
    final dir = Directory(homeDir);
    return dir.list().toList();
  }

  Widget buildFileSystemItem(FileSystemEntity entity) {
    final textWidget = Text(entity.path.split("/").last);
    var icon = Icons.file_copy;
    switch (entity) {
      case File _:
        icon = Icons.file_copy;
      case Directory _:
        icon = Icons.folder;
      default:
        icon = Icons.link;
    }
    return Row(spacing: 4, children: [Icon(icon), textWidget]);
  }

  Widget buildTopBar() {
    if (_mode == Mode.list) {
      return Row(
        children: [
          IconButton(
            onPressed: () => setState(() => _mode = Mode.search),
            icon: const Icon(Icons.search),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: TextField()),
        IconButton(
          onPressed: () => setState(() => _mode = Mode.list),
          icon: const Icon(Icons.arrow_back),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          buildTopBar(),
          FutureBuilder(
            future: getDirContent(),
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.connectionState == .waiting) {
                return Container(
                  alignment: .topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const CircularProgressIndicator(),
                  ),
                );
              }
              final items = asyncSnapshot.data
                ?..sort(
                  (a, b) => a.runtimeType.toString().compareTo(
                    b.runtimeType.toString(),
                  ),
                );
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    key: ValueKey("List ${items.hashCode}"),
                    physics: const AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) =>
                        buildFileSystemItem(asyncSnapshot.data![index]),
                    itemCount: asyncSnapshot.data!.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
