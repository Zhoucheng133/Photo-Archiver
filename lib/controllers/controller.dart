import 'dart:convert';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ffi';
import 'package:photo_archiver/dialog/dialogs.dart';

enum GroupBy{
  day,
  month,
  year
}

class PhotoData{
  String dir;
  String name;
  int year;
  int month;
  int day;

  PhotoData(this.dir, this.name, this.year, this.month, this.day);

  factory PhotoData.decode(Map map){
    DateTime dateTime = DateTime.parse(map["datetime"].replaceAll('/', '-'));
    int year = dateTime.year;
    int month = dateTime.month;
    int day = dateTime.day;

    return PhotoData(map["dir"], map["name"], year, month, day);
  }
}

typedef ScanDir = Pointer<Utf8> Function(Pointer<Utf8>);

class Controller extends GetxController {

  RxString dir="".obs;
  RxList<PhotoData> photoList=RxList([]);
  Rx<GroupBy> groupBy=Rx(GroupBy.month);
  RxBool loading=false.obs;

  RxList<int> years=RxList([]);
  RxList<int> month=RxList([]);
  RxList<int> days=RxList([]);

  RxMap<String, List<PhotoData>> groupedData=RxMap({});

 void groupHandler({GroupBy? groupBy}){
    groupBy = groupBy ?? this.groupBy.value;
    final Map<String, List<PhotoData>> grouped = {};
    for (var photo in photoList) {
      String key;
      switch (groupBy) {
        case GroupBy.year:
          key='${photo.year}';
          break;
        case GroupBy.month:
          key="${photo.year}年${photo.month}月";
          break;
        case GroupBy.day:
          key="${photo.year}年${photo.month}月${photo.day}日";
          break;
      }
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(photo);
    }
    groupedData.value=grouped;
  }

  static List isolateScan(String dir){
    final dynamicLib=DynamicLibrary.open(Platform.isMacOS ? 'core.dylib' : 'core.dll');
    final ScanDir scanDir=dynamicLib.lookup<NativeFunction<ScanDir>>("ScanDir").asFunction();
    final data=scanDir(dir.toNativeUtf8()).toDartString();
    return jsonDecode(data);
  }

  Future<void> analyseDir(String dir, BuildContext context) async {
    loading.value=true;
    List list=await compute(isolateScan, dir);
    if(list.isEmpty && context.mounted){
      showErrWarnDialog(context, "无法解析文件夹", "文件夹中不含任何图片文件或者无法解析任意一个图片文件");
      return;
    }
    loading.value=false;

    photoList.value=list.map((item)=>PhotoData.decode(item)).toList();
    groupHandler();
    this.dir.value=dir;
  }
}