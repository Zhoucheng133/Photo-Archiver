import 'dart:convert';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ffi';

import 'package:photo_archiver/dialog/dialogs.dart';

class PhotoData{
  String dir;
  String name;
  String datetime;

  PhotoData(this.dir, this.name, this.datetime);

  factory PhotoData.decode(Map map){
    return PhotoData(map["dir"], map["name"], map["datetime"]);
  }
}

typedef ScanDir = Pointer<Utf8> Function(Pointer<Utf8>);

class Controller extends GetxController {

  late ScanDir scanDir;

  void initLib(){
    final dynamicLib=DynamicLibrary.open(Platform.isMacOS ? 'core.dylib' : 'core.dll');
    scanDir=dynamicLib.lookup<NativeFunction<ScanDir>>("ScanDir").asFunction();
  }

  Controller(){
    initLib();
  }

  RxString dir="".obs;
  RxList<PhotoData> photoList=RxList([]);

  void analyseDir(String dir, BuildContext context){
    final data=scanDir(dir.toNativeUtf8()).toDartString();
    List list=jsonDecode(data);
    if(list.isEmpty){
      showErrWarnDialog(context, "无法解析文件夹", "文件夹中不含任何图片文件或者无法解析任意一个图片文件");
      return;
    }
    photoList.value=list.map((item)=>PhotoData.decode(item)).toList();
    this.dir.value=dir;
  }
}