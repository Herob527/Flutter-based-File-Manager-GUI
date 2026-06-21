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
  Future<List<FileSystemEntity>> getDirContent() {
    final homeDir = Platform.environment['HOME'];
    if (homeDir == null) {
      throw Exception('HOME environment variable is not set');
    }
    final dir = Directory(homeDir);
    return dir.list().toList();
  }

  Widget buildFileSystemItem(FileSystemEntity entity) {
    switch (entity.runtimeType) {
      case File _:
        return Text(entity.path);
      case Directory _:
        return Text(entity.path);
      default:
        return Text(entity.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: getDirContent(),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            return ListView.builder(
              itemBuilder: (context, index) =>
                  buildFileSystemItem(asyncSnapshot.data![index]),
              itemCount: asyncSnapshot.data!.length,
            );
          },
        ),
      ),
    );
  }
}
