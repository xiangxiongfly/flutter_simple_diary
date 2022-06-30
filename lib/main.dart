import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'EditNodePage.dart';
import 'FileUtils.dart';
import 'NoteInfo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter日记本',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: '日记本'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<NoteInfo> noteList = [];

  @override
  void initState() {
    loadNotes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: noteList.isEmpty ? _buildEmpty() : _buildList(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue,
        onPressed: () async {
          var result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return const EditNodePage();
          }));
          loadNotes();
        },
      ),
    );
  }

  /// 空页面
  _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.hourglass_empty_sharp,
            color: Colors.black.withOpacity(0.6),
            size: 40,
          ),
          Text(
            "空空如也，快来写日记",
            style: TextStyle(color: Colors.black.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  _buildList() {
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () async {
            var result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return EditNodePage(path: noteList[index].path);
            }));
            loadNotes();
          },
          child: ListTile(
            title: Text(noteList[index].name),
            subtitle: Text("${noteList[index].updateTime}"),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(height: 1),
      itemCount: noteList.length,
    );
  }

  /// 加载日记
  loadNotes() async {
    var parentDir = await getTemporaryDirectory();
    List<FileSystemEntity> dirList = parentDir.listSync(recursive: false);
    List<FileSystemEntity> fileList = [];
    for (var dir in dirList) {
      if ((await dir.stat()).type == FileSystemEntityType.file) {
        fileList.add(dir);
      }
    }
    fileList.sort((f1, f2) {
      try {
        DateTime dateTime1 = File(f1.path).lastModifiedSync();
        DateTime dateTime2 = File(f2.path).lastModifiedSync();
        return dateTime2.microsecondsSinceEpoch - dateTime1.microsecondsSinceEpoch;
      } catch (e) {
        return 0;
      }
    });
    noteList.clear();
    for (var f in fileList) {
      File file = File(f.path);
      if (file.path.endsWith("txt")) {
        noteList.add(NoteInfo(FileUtils.getFileName(file.path), file.path, file.lastModifiedSync()));
      }
    }
    setState(() {});
  }
}
