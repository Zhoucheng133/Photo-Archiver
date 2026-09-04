import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;

enum GroupBy{
  day,
  month,
  year
}

String groupByToString(GroupBy groupBy){
  switch (groupBy) {
    case GroupBy.day:
      return "year-month-day".tr;
    case GroupBy.month:
      return "year-month".tr;
    case GroupBy.year:
      return "year".tr;
  }
}

class PhotoData{
  String dir;
  String name;
  int year;
  int month;
  int day;
  String country;
  String city;

  PhotoData(this.dir, this.name, this.year, this.month, this.day, this.country, this.city);

  factory PhotoData.decode(Map map){
    try {
      DateTime dateTime = DateTime.parse(map["datetime"].replaceAll('/', '-'));
      int year = dateTime.year;
      int month = dateTime.month;
      int day = dateTime.day;

      return PhotoData(map["dir"], map["name"], year, month, day, (map["country"] as String).trim(), (map["city"] as String).trim());
    } catch (_) {
      throw FormatException('PhotoData.decode failed');
    }
  }

  String getDate(){
    return "$year/$month/$day";
  }

  Map toJson(){
    return {
      "dir": dir,
      "name": name,
      "datetime": "$year-$month-$day",
      "country": country,
      "city": city
    };
  }
}

typedef ScanDir = Pointer<Utf8> Function(Pointer<Utf8>);
typedef GetPhoto = Pointer<Utf8> Function(Pointer<Utf8>);

class Handler extends GetxController{

  RxBool stop=false.obs;
  RxBool loading=false.obs;
  RxList<PhotoData> photos=<PhotoData>[].obs;
  RxString nowFile="".obs;

  static PhotoData? getPhotoData(List params) {
    try {
      final dynamicLib = DynamicLibrary.open(
        Platform.isMacOS ? 'core.dylib' : 'core.dll',
      );

      final getPhoto = dynamicLib
        .lookup<NativeFunction<GetPhoto>>('GetPhoto')
        .asFunction<GetPhoto>();

      String path=params[0];

      final photo = getPhoto(path.toNativeUtf8()).toDartString();

      return PhotoData.decode(jsonDecode(photo));
    } catch (e) {
      return null;
    }
  }

  Future<void> scan(String dir) async {
    loading.value=true;
    await for (final entity in Directory(dir).list(recursive: false)){
      if (stop.value){
        stop.value=false;
        break;
      }
      if (entity is! File) continue;
      nowFile.value=p.basename(entity.path);
      PhotoData? photoData = await compute(getPhotoData, [entity.path]);
      if (photoData!=null){
        photos.add(photoData);
      }
    }
    for (var element in photos) {
      print(element.toJson());
    }
    loading.value=false;
    nowFile.value="";
  }

  void stopScan(){
    stop.value=true;
  }
}