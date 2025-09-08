import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_archiver/controllers/controller.dart';

class SidebarItem extends StatefulWidget {

  final int index;

  const SidebarItem({super.key, required this.index});

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {

  final Controller controller=Get.find();
  bool hover=false;

  Color buttonColor(bool hover, bool selected){
    if(Theme.of(context).brightness==Brightness.light){
      return selected ? Theme.of(context).colorScheme.primary.withAlpha(18) : hover ? Theme.of(context).colorScheme.primary.withAlpha(12) : Theme.of(context).colorScheme.primary.withAlpha(0);
    }else{
      return selected ? Color.fromARGB(255, 60, 60, 60) : hover ? Color.fromARGB(255, 40, 40, 40) : Theme.of(context).colorScheme.surface;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 3),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_)=>setState(() {
          hover=true;
        }),
        onExit: (_)=>setState(() {
          hover=false;
        }),
        child: GestureDetector(
          onTap: ()=>controller.selectedKey.value=widget.index,
          child: Obx(
            ()=> AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: buttonColor(false, controller.selectedKey.value==widget.index)
              ),
              height: 40,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(controller.groupedData.keys.toList()[widget.index]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}