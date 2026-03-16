import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_archiver/components/sidebar_item.dart';
import 'package:photo_archiver/controllers/controller.dart';

class GroupView extends StatefulWidget {
  const GroupView({super.key});

  @override
  State<GroupView> createState() => _GroupViewState();
}

class _GroupViewState extends State<GroupView> {

  final Controller controller=Get.find();

  bool loading=false;

  Color buttonColor(BuildContext context, bool hover, bool selected){
    if(Theme.of(context).brightness==Brightness.light){
      return selected ? Theme.of(context).colorScheme.primary.withAlpha(18) : hover ? Theme.of(context).colorScheme.primary.withAlpha(12) : Theme.of(context).colorScheme.primary.withAlpha(0);
    }else{
      return selected ? Color.fromARGB(255, 60, 60, 60) : hover ? Color.fromARGB(255, 40, 40, 40) : Theme.of(context).colorScheme.surface;
    }
  }

  TextEditingController outputText=TextEditingController();

  @override
  void initState() {
    super.initState();

    setState(() {
      outputText.text=controller.dir.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 200,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Obx(
                        ()=> DropdownButtonHideUnderline(
                          child: DropdownButton2(
                            value: controller.groupBy.value,
                            buttonStyleData: ButtonStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)
                              )
                            ),
                            customButton: MouseRegion(
                              cursor: SystemMouseCursors.basic,
                              child: Container(
                                width: double.infinity,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10, right: 10),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          groupByToString(controller.groupBy.value),
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        )
                                      ),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        size: 22,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            menuItemStyleData: MenuItemStyleData(
                              height: 45,
                            ),
                            dropdownStyleData: DropdownStyleData(
                              padding: const EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).colorScheme.surface
                              )
                            ),
                            isExpanded: true,
                            items: GroupBy.values.map((item)=>
                              DropdownMenuItem(
                                value: item,
                                child: Text(groupByToString(item)),
                              )
                            ).toList(),
                            onChanged: (val){
                              if(val!=null){
                                controller.selectedKey.value=0;
                                controller.groupBy.value=val;
                                controller.groupHandler();
                              }
                            },
                          )
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Obx(()=>
                          ListView.builder(
                            itemCount: controller.groupedData.length,
                            itemBuilder: (BuildContext context, int index)=>SidebarItem(index: index)
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 15, bottom: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness==Brightness.dark ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Obx(
                      ()=> Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15, top: 15, right: 15),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    controller.groupedData.keys.toList()[controller.selectedKey.value],
                                    style: TextStyle(
                                      fontSize: 20
                                    ),
                                  ),
                                ),
                                Text(
                                  "${controller.groupedData.values.toList()[controller.selectedKey.value].length}张照片",
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Divider(),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: controller.groupedData.values.toList()[controller.selectedKey.value].length,
                              itemBuilder: (BuildContext context, int index)=>Material(
                                child: ListTile(
                                  tileColor: Theme.of(context).brightness==Brightness.light ? Colors.white : Colors.grey[900],
                                  minTileHeight: 40,
                                  mouseCursor: SystemMouseCursors.basic,
                                  title: Text(
                                    controller.groupedData.values.toList()[controller.selectedKey.value][index].name,
                                    style: TextStyle(
                                      fontSize: 15
                                    ),
                                  ),
                                  subtitle: Text(
                                    controller.groupedData.values.toList()[controller.selectedKey.value][index].getDate(),
                                    style: TextStyle(
                                      fontSize: 13
                                    ),
                                  ),
                                  onTap: ()=>controller.previewPhoto(context, index),
                                ),
                              )
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: ()=>controller.closeDir(), 
                icon: Icon(
                  Icons.close_rounded
                )
              ),
              const SizedBox(width: 10,),
              Expanded(
                child: TextField(
                  enabled: false,
                  controller: outputText,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12)
                  ),
                  style: TextStyle(
                    fontSize: 14
                  ),
                )
              ),
              const SizedBox(width: 10,),
              FilledButton(
                onPressed: loading ? null : () async {
                  setState(() {
                    loading=true;
                  });
                  await controller.movePhotos(context);
                  setState(() {
                    loading=false;
                  });
                  controller.closeDir();
                }, 
                child: const Text('整理')
              )
            ],
          ),
        )
      ],
    );
  }
}