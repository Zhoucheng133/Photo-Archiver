import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:photo_archiver/controllers/controller.dart';
import 'package:photo_archiver/dialog/dialogs.dart';
import 'package:photo_archiver/views/config_view.dart';

String locationString(PhotoData photoData){
  if(photoData.city.isEmpty && photoData.country.isEmpty){
    return "unkownLocation".tr;
  }
  return "${photoData.city} ${photoData.country}";
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

  factory PhotoData.decode(Map map, String locale){
    try {
      DateTime dateTime = DateTime.parse(map["datetime"].replaceAll('/', '-'));
      int year = dateTime.year;
      int month = dateTime.month;
      int day = dateTime.day;
      String city = map['city'][locale];
      String country = map['country'][locale];

      return PhotoData(map["dir"], map["name"], year, month, day, country, city);
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
      final pathPtr = path.toNativeUtf8();
      String locale=params[1];

      try {
        final photo = getPhoto(pathPtr).toDartString();
        return PhotoData.decode(jsonDecode(photo), locale);
      } finally {
        calloc.free(pathPtr);
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> scan(String dir) async {
    final Controller controller=Get.find();
    loading.value=true;
    await for (final entity in Directory(dir).list(recursive: false)){
      if (stop.value){
        stop.value=false;
        break;
      }
      if (entity is! File) continue;
      nowFile.value=p.basename(entity.path);
      PhotoData? photoData = await compute(getPhotoData, [
        entity.path, 
        controller.lang.value.locale.languageCode.toLowerCase()+controller.lang.value.locale.countryCode!.toUpperCase()
      ]);
      if (photoData!=null){
        photos.add(photoData);
      }
    }
    loading.value=false;
    nowFile.value="";
  }

  void stopScan(){
    stop.value=true;
  }

  Future<void> archivePhotos({
    required ArchiveMode mode,
    required ConfigMode configMode,
    required TimeLevel timeLevel,
    required LocationLevel locationLevel,
    String? targetDirectory,
    required Controller controller,
  }) async {
    loading.value = true;
    for (var photo in photos) {
      if (stop.value) {
        stop.value = false;
        break;
      }
      
      String subFolder = "";
      if (configMode == ConfigMode.time) {
        if (timeLevel == TimeLevel.y) {
          subFolder = DateFormat.y("${controller.lang.value.locale.languageCode}_${controller.lang.value.locale.countryCode}").format(DateTime(photo.year));
        } else if (timeLevel == TimeLevel.ym) {
          subFolder = DateFormat.yMMM("${controller.lang.value.locale.languageCode}_${controller.lang.value.locale.countryCode}").format(DateTime(photo.year, photo.month));
        } else {
          subFolder = DateFormat.yMMMd("${controller.lang.value.locale.languageCode}_${controller.lang.value.locale.countryCode}").format(DateTime(photo.year, photo.month, photo.day));
        }
      } else {
        if (locationLevel == LocationLevel.country) {
          subFolder = photo.country.isEmpty ? "unkownLocation".tr : photo.country;
        } else {
          subFolder = photo.city.isEmpty ? "unkownLocation".tr : photo.city;
        }
        if (subFolder == "unkownLocation".tr) {
          continue;
        }
      }

      String baseDir = (mode == ArchiveMode.specCopy || mode == ArchiveMode.specMove) ? (targetDirectory ?? photo.dir) : photo.dir;
      Directory destDir = Directory(p.join(baseDir, subFolder));
      if (!await destDir.exists()) {
        await destDir.create(recursive: true);
      }

      File sourceFile = File(p.join(photo.dir, photo.name));
      if (await sourceFile.exists()) {
        String destPath = p.join(destDir.path, photo.name);
        nowFile.value = photo.name;
        if (mode == ArchiveMode.specMove || mode == ArchiveMode.curMove) {
          await sourceFile.rename(destPath);
          photo.dir = destDir.path;
        } else {
          await sourceFile.copy(destPath);
        }
      }
    }
    loading.value = false;
    nowFile.value = "";
  }
}