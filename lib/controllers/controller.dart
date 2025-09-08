import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ffi';
import 'package:photo_archiver/dialog/dialogs.dart';
import 'package:path/path.dart' as p;

enum GroupBy{
  day,
  month,
  year
}

String groupByToString(GroupBy groupBy){
  switch (groupBy) {
    case GroupBy.day:
      return "年-月-日";
    case GroupBy.month:
      return "年-月";
    case GroupBy.year:
      return "年份";
  }
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

  String getDate(){
    return "$year/$month/$day";
  }
}

typedef ScanDir = Pointer<Utf8> Function(Pointer<Utf8>);
typedef GetPhoto = Pointer<Utf8> Function(Pointer<Utf8>);

class Controller extends GetxController {

  RxString dir="".obs;
  RxList<PhotoData> photoList=RxList([]);
  Rx<GroupBy> groupBy=Rx(GroupBy.month);
  RxBool loading=false.obs;
  RxString nowFile="".obs;

  RxList<int> years=RxList([]);
  RxList<int> month=RxList([]);
  RxList<int> days=RxList([]);

  RxInt selectedKey=0.obs;

  RxMap<String, List<PhotoData>> groupedData=RxMap({});


  Future<void> movePhotos(BuildContext context) async {
    for (var entry in groupedData.entries) {
      String key = entry.key;
      List<PhotoData> photos = entry.value;

      for (var photo in photos) {
        String newDirPath = '${photo.dir}/$key';
        Directory newDir = Directory(newDirPath);

        if (!await newDir.exists()) {
          await newDir.create(recursive: true);
        }

        File sourceFile = File('${photo.dir}/${photo.name}');
        File targetFile = File('$newDirPath/${photo.name}');

        try {
          await sourceFile.rename(targetFile.path);
        } catch (_) {}
      }
    }
    if(context.mounted) showErrWarnDialog(context, "整理完成", "已经将所有图片文件以${groupByToString(groupBy.value)}方式整理");
  }

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
    var sortedKeys = grouped.keys.toList()..sort();
    groupedData.value={ for (var k in sortedKeys) k: grouped[k]! };
  }

  static Future<void> isolateScan(List args) async {
    // final dynamicLib=DynamicLibrary.open(Platform.isMacOS ? 'core.dylib' : 'core.dll');
    // final ScanDir scanDir=dynamicLib.lookup<NativeFunction<ScanDir>>("ScanDir").asFunction();
    // final data=scanDir(dir.toNativeUtf8()).toDartString();
    // return jsonDecode(data);
    final dir = args[0] as String;
    final sendPort = args[1] as SendPort;
    final dynamicLib=DynamicLibrary.open(Platform.isMacOS ? 'core.dylib' : 'core.dll');
    final GetPhoto getPhoto=dynamicLib.lookup<NativeFunction<GetPhoto>>("GetPhoto").asFunction();

    try {
      await for (final entity in Directory(dir).list(recursive: false)){
        if (entity is! File) continue;
        sendPort.send({
          'type': 'progress_start',
          'path': entity.path,
        });
        final pathPtr = entity.path.toNativeUtf8();
        final resPtr = getPhoto(pathPtr);
        final jsonStr = resPtr.toDartString();
        if (jsonStr.isEmpty) continue;
        sendPort.send({
          'type': 'photo',
          'photo': jsonStr,
        });
      }
      sendPort.send({'type': 'done'});
    } catch (_) {}
  }

  Future<void> analyseDir(String dir, BuildContext context) async {
    loading.value=true;
    
    final receivePort = ReceivePort();
    Isolate? isolate;
    try {
      isolate = await Isolate.spawn(isolateScan, [dir, receivePort.sendPort]);
    } catch (e) {
      loading.value = false;
      receivePort.close();
      return;
    }

    late final StreamSubscription sub;
    sub = receivePort.listen((message) {
      if (message is Map) {
        switch (message['type']) {
          case 'progress_start':
            final String path = message['path'] ?? "";
            nowFile.value=p.basename(path);
            break;
          case 'photo':
            final String photo=message['photo'];
            photoList.add(PhotoData.decode(jsonDecode(photo)));
            break;
          case 'done':
            if(photoList.isEmpty){
              showErrWarnDialog(context, "无法解析文件夹", "文件夹中不含任何图片文件或者无法解析任意一个图片文件");
            }
            loading.value = false;
            groupHandler();
            this.dir.value=dir;
            sub.cancel();
            receivePort.close();
            isolate?.kill(priority: Isolate.immediate);
            break;
        }
      }
    });
  }
}