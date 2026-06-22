import 'dart:io';

import 'package:file_manager_ripgrep_test/core/services/file_system_service.dart';
import 'package:file_manager_ripgrep_test/init.dart';
import 'package:flutter/material.dart';

void main() {
  configureDependencies();
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

enum Mode { list, search }

class _MyHomePageState extends State<MyHomePage> {
  var _mode = Mode.list;
  final FileSystemService fileSystemService = getIt<FileSystemService>();
  String _currentDir = getIt<FileSystemService>().homeDir;

  Widget buildFileSystemItem(FileSystemEntity entity, bool isFirst) {
    final textWidget = Text(entity.path.split("/").last);
    IconButton icon;
    switch (entity) {
      case File _:
        icon = IconButton(onPressed: () {}, icon: Icon(Icons.file_copy));
      case Directory _:
        icon = IconButton(
          onPressed: () {
            setState(() {
              _currentDir = entity.path;
            });
          },
          icon: Icon(Icons.folder),
        );
      case Link _:
        icon = IconButton(onPressed: () {}, icon: Icon(Icons.link));
      default:
        icon = IconButton(onPressed: () {}, icon: Icon(Icons.question_mark));
    }
    if (isFirst) {
      return Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            spacing: 4,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentDir = (_currentDir.split(
                      "/",
                    )..removeLast()).join("/");
                  });
                },
                icon: Icon(Icons.folder),
              ),
              Text(".."),
            ],
          ),
          Row(spacing: 4, children: [icon, textWidget]),
        ],
      );
    }
    return Row(spacing: 4, children: [icon, textWidget]);
  }

  Widget buildTopBar() {
    if (_mode == Mode.list) {
      return Row(
        children: [
          IconButton(
            onPressed: () => setState(() => _mode = Mode.search),
            icon: const Icon(Icons.search),
          ),
          Expanded(child: Text(_currentDir)),
        ],
      );
    }
    return Row(
      children: [
        IconButton(
          onPressed: () => setState(() => _mode = Mode.list),
          icon: const Icon(Icons.arrow_back),
        ),

        Expanded(child: TextField()),
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
            future: fileSystemService.getDirContent(_currentDir),
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.connectionState == .waiting ||
                  asyncSnapshot.connectionState == .none ||
                  asyncSnapshot.data == null) {
                return Container(
                  alignment: .topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const CircularProgressIndicator(),
                  ),
                );
              }
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    key: ValueKey("List ${asyncSnapshot.hashCode}"),
                    physics: const AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) => buildFileSystemItem(
                      asyncSnapshot.data![index],
                      index == 0,
                    ),
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
