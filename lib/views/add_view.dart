import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        // final dirPath=detail.files[0].path.replaceAll("\\", "/");
        // TODO analyse
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
                      // TODO analyse
                    }
                  }, 
                  icon: const Icon(Icons.add_rounded)
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text("addDir".tr),
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
                      FaIcon(
                        FontAwesomeIcons.language,
                        size: 13,
                      ),
                      SizedBox(width: 5,),
                      Text("language".tr),
                    ],
                  )
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  ),
                  onPressed: ()=>darkModePanel(context), 
                  child: Row(
                    mainAxisSize: .min,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.circleHalfStroke,
                        size: 13,
                      ),
                      SizedBox(width: 5,),
                      Text("darkMode".tr),
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
                      FaIcon(
                        FontAwesomeIcons.circleInfo,
                        size: 13,
                      ),
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