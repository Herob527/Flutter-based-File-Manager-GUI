import 'dart:async';
import 'dart:io';

import 'package:file_manager_ripgrep_test/core/services/file_system_service.dart';
import 'package:file_manager_ripgrep_test/core/services/search_service.dart';
import 'package:file_manager_ripgrep_test/init.dart';
import 'package:flutter/material.dart';

const defaultDebounce = Duration(milliseconds: 300);
const initialValue = "test";

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
  final SearchService searchService = getIt<SearchService>();
  String _currentDir = getIt<FileSystemService>().homeDir;
  String _searchQuery = initialValue;

  Timer? _debounceTimer;
  TextEditingController? queryController = .new(text: initialValue);

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

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
    if (isFirst && !fileSystemService.isRoot(_currentDir)) {
      return Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            spacing: 4,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentDir = fileSystemService.getParent(_currentDir);
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
    return Row(
      key: ValueKey(entity.path),
      spacing: 4,
      children: [icon, textWidget],
    );
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

        Expanded(
          child: TextField(
            controller: queryController,
            onChanged: (query) {
              _debounceTimer?.cancel();
              _debounceTimer = Timer(defaultDebounce, () {
                setState(() {
                  _searchQuery = query;
                });
              });
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final usedService = switch (_mode) {
      .list => fileSystemService.getDirContent(_currentDir),
      .search => searchService.search(_searchQuery, _currentDir),
    };
    return Scaffold(
      body: Column(
        children: [
          buildTopBar(),
          FutureBuilder(
            future: usedService,
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
              if (asyncSnapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Search failed. Please try again."),
                );
              }
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
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
