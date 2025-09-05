import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class MainWindow extends StatefulWidget {
  const MainWindow({super.key});

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> with WindowListener {

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
        Row(
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

        Expanded(
          child: Center(
            child: TextButton(
              onPressed: (){
                showDialog(
                  context: context, 
                  builder: (BuildContext context)=>AlertDialog(
                    title: const Text("Text Label"),
                    content: const Text("Test Content"),
                  )
                );
              }, 
              child: const Text("Test")
            ),
          )
        )
      ],
    );
  }
}