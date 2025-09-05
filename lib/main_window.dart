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
            WindowCaptionButton.minimize(
              onPressed: ()=>windowManager.minimize()
            ),
            isMax ?
            WindowCaptionButton.unmaximize(
              onPressed: ()=>windowManager.unmaximize()
            ):
            WindowCaptionButton.maximize(
              onPressed: ()=>windowManager.maximize()
            ),  
            WindowCaptionButton.close(
              onPressed: ()=>windowManager.close()
            ),
          ],
        ),
      ],
    );
  }
}