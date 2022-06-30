import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'FileUtils.dart';

class EditNodePage extends StatefulWidget {
  final String? path;

  const EditNodePage({Key? key, this.path}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EditNodePageState();
  }
}

class _EditNodePageState extends State<EditNodePage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    loadData();
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("编辑"),
        actions: [
          IconButton(onPressed: save, icon: const Icon(Icons.done)),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: "请输入日记名称"),
              ),
              Expanded(
                child: TextField(
                  textAlignVertical: TextAlignVertical.top,
                  controller: _contentController,
                  decoration: const InputDecoration(hintText: "开始你的故事"),
                  maxLength: 2000,
                  maxLines: null,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  loadData() async {
    if (widget.path != null) {
      String fileName = FileUtils.getFileName(widget.path);
      String content = const Utf8Decoder().convert(await File(widget.path!).readAsBytes());
      setState(() {
        _titleController.text = fileName;
        _contentController.text = content;
      });
    }
  }

  save() async {
    try {
      String title = _titleController.text;
      String content = _contentController.text;
      var parentDir = await getTemporaryDirectory();
      var file = File("${parentDir.path}/$title.txt");
      bool exists = file.existsSync();
      if (!exists) {
        file.createSync();
      }
      file.writeAsStringSync(content);
      Navigator.of(context).pop(title);
    } on Exception catch (e) {
      print(e);
    }
  }
}
