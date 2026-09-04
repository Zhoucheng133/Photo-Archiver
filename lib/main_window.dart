import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_archiver/controllers/controller.dart';
import 'package:photo_archiver/controllers/handler.dart';
import 'package:photo_archiver/dialog/dialogs.dart';
import 'package:photo_archiver/views/add_view.dart';
import 'package:photo_archiver/views/config_view.dart';
import 'package:photo_archiver/views/loading_view.dart';
import 'package:window_manager/window_manager.dart';

class MainWindow extends StatefulWidget {
  const MainWindow({super.key});

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> with WindowListener {

  final Controller controller=Get.find();
  final Handler handler=Get.find();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

 @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  bool isMax=false;

  @override
  void onWindowMaximize(){
    setState(() {
      isMax=true;
    });
  }
  
  @override
  void onWindowUnmaximize(){
    setState(() {
      isMax=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 30,
          child: Row(
            children: [
              Expanded(child: DragToMoveArea(child: Container())),
              if(Platform.isWindows) Row(
                children: [
                  WindowCaptionButton.minimize(
                    brightness: Theme.of(context).brightness,
                    onPressed: ()=>windowManager.minimize()
                  ),
                  isMax ? WindowCaptionButton.unmaximize(
                    brightness: Theme.of(context).brightness,
                    onPressed: ()=>windowManager.unmaximize()
                  ) : WindowCaptionButton.maximize(
                    brightness: Theme.of(context).brightness,
                    onPressed: ()=>windowManager.maximize()
                  ),  
                  WindowCaptionButton.close(
                    brightness: Theme.of(context).brightness,
                    onPressed: ()=>windowManager.close()
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(()=>
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: handler.loading.value ?
                LoadingView(key: ValueKey("loading"),) : handler.photos.isEmpty ?
                AddView(key: ValueKey("add"),) : ConfigView(key: ValueKey("config"),),
            )
          )
        ),
        Platform.isMacOS ? PlatformMenuBar(
          menus: [
            PlatformMenu(
              label: "Photo Archiver",
              menus: [
                PlatformMenuItemGroup(
                  members: [
                    PlatformMenuItem(
                      label: "${'about'.tr} Photo Archiver",
                      onSelected: (){
                        showAbout(context);
                      }
                    )
                  ]
                ),
                const PlatformMenuItemGroup(
                  members: [
                    PlatformProvidedMenuItem(
                      enabled: true,
                      type: PlatformProvidedMenuItemType.hide,
                    ),
                    PlatformProvidedMenuItem(
                      enabled: true,
                      type: PlatformProvidedMenuItemType.quit,
                    ),
                  ]
                ),
              ]
            ),
            PlatformMenu(
              label: "编辑",
              menus: [
                PlatformMenuItem(
                  label: "拷贝",
                  onSelected: (){
                    final focusedContext = FocusManager.instance.primaryFocus?.context;
                    if (focusedContext != null) {
                      Actions.invoke(focusedContext, CopySelectionTextIntent.copy);
                    }
                  }
                ),
                PlatformMenuItem(
                  label: "粘贴",
                  onSelected: (){
                    final focusedContext = FocusManager.instance.primaryFocus?.context;
                    if (focusedContext != null) {
                      Actions.invoke(focusedContext, const PasteTextIntent(SelectionChangedCause.keyboard));
                    }
                  },
                ),
                PlatformMenuItem(
                  label: "全选",
                  onSelected: (){
                    final focusedContext = FocusManager.instance.primaryFocus?.context;
                    if (focusedContext != null) {
                      Actions.invoke(focusedContext, const SelectAllTextIntent(SelectionChangedCause.keyboard));
                    }
                  }
                )
              ]
            ),
            const PlatformMenu(
              label: "窗口", 
              menus: [
                PlatformMenuItemGroup(
                  members: [
                    PlatformProvidedMenuItem(
                      enabled: true,
                      type: PlatformProvidedMenuItemType.minimizeWindow,
                    ),
                    PlatformProvidedMenuItem(
                      enabled: true,
                      type: PlatformProvidedMenuItemType.toggleFullScreen,
                    )
                  ]
                )
              ]
            )
          ]
        ) : Container()
      ],
    );
  }
}