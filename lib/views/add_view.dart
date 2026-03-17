import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_archiver/controllers/controller.dart';
import 'package:photo_archiver/dialog/dialogs.dart';

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
      child: Stack(
        children: [
          Center(
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
          Positioned(
            right: 30,
            bottom: 30,
            child: Row(
              mainAxisSize: .min,
              mainAxisAlignment: .center,
              crossAxisAlignment: .center,
              children: [
                FilledButton(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10)
                      )
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  ),
                  onPressed: ()=>showLanguageDialog(context), 
                  child: Row(
                    mainAxisSize: .min,
                    children: [
                      Icon(Icons.translate_rounded),
                      SizedBox(width: 5,),
                      Text("language".tr),
                    ],
                  )
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10)
                      )
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  ),
                  onPressed: ()=>showAbout(context), 
                  child: Row(
                    mainAxisSize: .min,
                    children: [
                      Icon(Icons.info_rounded),
                      SizedBox(width: 5,),
                      Text("about".tr),
                    ],
                  )
                ),
              ],
            )
          )
        ],
      ),
    );
  }
}