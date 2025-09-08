import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_archiver/components/sidebar_item.dart';
import 'package:photo_archiver/controllers/controller.dart';

class GroupView extends StatefulWidget {
  const GroupView({super.key});

  @override
  State<GroupView> createState() => _GroupViewState();
}

class _GroupViewState extends State<GroupView> {

  final Controller controller=Get.find();

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
                  padding: const EdgeInsets.only(right: 15, bottom: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Obx(
                        ()=> Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                controller.groupedData.keys.toList()[controller.selectedKey.value],
                                style: GoogleFonts.notoSansSc(
                                  fontSize: 20
                                ),
                              )
                            ),
                            Divider(),
                            Expanded(
                              child: ListView.builder(
                                itemCount: controller.groupedData.values.toList()[controller.selectedKey.value].length,
                                itemBuilder: (BuildContext context, int index)=>ListTile(
                                  contentPadding: EdgeInsets.only(left: 0),
                                  minTileHeight: 40,
                                  title: Text(
                                    controller.groupedData.values.toList()[controller.selectedKey.value][index].name,
                                    style: GoogleFonts.notoSansSc(
                                      fontSize: 15
                                    ),
                                  ),
                                  subtitle: Text(
                                    controller.groupedData.values.toList()[controller.selectedKey.value][index].getDate(),
                                    style: GoogleFonts.notoSansSc(
                                      fontSize: 13
                                    ),
                                  ),
                                )
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: (){
                  controller.dir.value="";
                }, 
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
                    hintText: '随意取一个',
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12)
                  ),
                  style: GoogleFonts.notoSansSc(
                    fontSize: 14
                  ),
                )
              ),
              const SizedBox(width: 10,),
              FilledButton(
                onPressed: (){
                  controller.movePhotos(context);
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