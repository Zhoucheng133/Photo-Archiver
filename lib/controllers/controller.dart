import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ffi';

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

  void analyseDir(String dir, BuildContext context){
    final data=scanDir(dir.toNativeUtf8()).toDartString();
    print(data);
  }
}