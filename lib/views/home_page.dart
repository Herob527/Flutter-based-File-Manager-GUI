import 'dart:async';
import 'dart:io';

import 'package:file_manager_ripgrep_test/core/enums/search_backend.dart';
import 'package:file_manager_ripgrep_test/core/services/file_system_service.dart';
import 'package:file_manager_ripgrep_test/core/services/search_service.dart';
import 'package:file_manager_ripgrep_test/init.dart';
import 'package:flutter/material.dart';

const defaultDebounce = Duration(milliseconds: 300);
const initialValue = "test";

enum Mode { list, search }

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Services
  final FileSystemService fileSystemService = getIt<FileSystemService>();
  final SearchService searchService = getIt<SearchService>();

  // State
  String _searchQuery = initialValue;
  Mode _mode = .list;
  SearchBackends _backend = .ripgrep;

  // Dependent
  late String _currentDir = fileSystemService.homeDir;

  Timer? _debounceTimer;

  // Text inputs
  TextEditingController? queryController = .new(text: initialValue);

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Widget buildGoUpButton() {
    return Row(
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
    );
  }

  Widget buildFileSystemItem(FileSystemEntity entity, bool isFirst) {
    final entityPath = entity.path.endsWith(fileSystemService.separator)
        ? entity.path.substring(0, entity.path.length - 1)
        : entity.path;
    final textWidget = Text(
      _mode == .search
          ? entityPath
          : entityPath.split(fileSystemService.separator).last,
    );
    IconButton icon;
    switch (entity) {
      case File _:
        icon = IconButton(
          onPressed: () {
            Process.start("xdg-open", [entity.path]);
          },
          icon: Icon(Icons.file_copy),
        );
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
        icon = IconButton(
          onPressed: () {
            Process.start("xdg-open", [entity.path]);
          },
          icon: Icon(Icons.link),
        );
      default:
        icon = IconButton(onPressed: () {}, icon: Icon(Icons.question_mark));
    }
    if (_mode == .list && isFirst && !fileSystemService.isRoot(_currentDir)) {
      return Column(
        crossAxisAlignment: .start,
        children: [
          buildGoUpButton(),
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
    if (_mode == .list) {
      return Row(
        children: [
          IconButton(
            onPressed: () => setState(() => _mode = .search),
            icon: const Icon(Icons.search),
          ),
          Expanded(child: Text(_currentDir)),
        ],
      );
    }
    return Row(
      children: [
        IconButton(
          onPressed: () => setState(() => _mode = .list),
          icon: const Icon(Icons.list),
        ),

        Expanded(
          child: Row(
            children: [
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
              DropdownButton(
                value: _backend,
                onChanged: (value) {
                  setState(() {
                    _backend = value!;
                  });
                },

                items: [
                  DropdownMenuItem(
                    value: SearchBackends.fdfind,
                    child: Text("fdfind"),
                  ),

                  DropdownMenuItem(
                    value: SearchBackends.ripgrep,
                    child: Text("ripgrep"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final usedService = switch (_mode) {
      .list => fileSystemService.getDirContent(_currentDir),
      .search => searchService.search(
        _searchQuery,
        _currentDir,
        backend: _backend,
      ),
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
              if (asyncSnapshot.data!.isEmpty) {
                return buildGoUpButton();
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
