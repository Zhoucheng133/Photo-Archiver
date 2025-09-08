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

  Color buttonColor(BuildContext context, bool hover, bool selected){
    if(Theme.of(context).brightness==Brightness.light){
      return selected ? Theme.of(context).colorScheme.primary.withAlpha(18) : hover ? Theme.of(context).colorScheme.primary.withAlpha(12) : Theme.of(context).colorScheme.primary.withAlpha(0);
    }else{
      return selected ? Color.fromARGB(255, 60, 60, 60) : hover ? Color.fromARGB(255, 40, 40, 40) : Theme.of(context).colorScheme.surface;
    }
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
                      borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                )
              )
            ],
          ),
        ),
      ],
    );
  }
}