import 'dart:convert';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ffi';
import 'package:photo_archiver/dialog/dialogs.dart';

enum ArchiveBy{
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
  Rx<ArchiveBy> archiveBy=Rx(ArchiveBy.month);
  RxBool loading=false.obs;

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
    this.dir.value=dir;
  }
}