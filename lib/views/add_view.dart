import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_archiver/controllers/controller.dart';

class AddView extends StatefulWidget {
  const AddView({super.key});

  @override
  State<AddView> createState() => _AddViewState();
}

class _AddViewState extends State<AddView> {

  final Controller controller=Get.find();

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (detail) async {
        final dirPath=detail.files[0].path.replaceAll("\\", "/");
        controller.analyseDir(dirPath, context);
      },
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () async {
                String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                if (selectedDirectory != null && context.mounted) {
                  controller.analyseDir(selectedDirectory, context);
                }
              }, 
              icon: const Icon(Icons.add_rounded)
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text("添加目录或拖动目录至此"),
            )
          ],
        ),
      ),
    );
  }
}