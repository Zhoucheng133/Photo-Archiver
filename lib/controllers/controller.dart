import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:ffi';
import 'package:photo_archiver/dialog/dialogs.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

class LanguageType{
  String name;
  Locale locale;

  LanguageType(this.name, this.locale);
}

List<LanguageType> get supportedLocales => [
  LanguageType("English", const Locale("en", "US")),
  LanguageType("简体中文", const Locale("zh", "CN")),
  LanguageType("繁體中文", const Locale("zh", "TW")),
];


class Controller extends GetxController {

  RxString dir="".obs;
  RxList<PhotoData> photoList=RxList([]);
  Rx<GroupBy> groupBy=Rx(GroupBy.month);
  RxBool loading=false.obs;
  RxString nowFile="".obs;

  Rx<LanguageType> lang=Rx(supportedLocales[0]);
  late SharedPreferences prefs;

  RxList<int> years=RxList([]);
  RxList<int> month=RxList([]);
  RxList<int> days=RxList([]);

  RxInt selectedKey=0.obs;

  Isolate? isolate;

  RxMap<String, List<PhotoData>> groupedData=RxMap({});

  Future<void> previewPhoto(BuildContext context, int index) async {

    final String imagePath=p.join(photoList[index].dir, photoList[index].name);
    File imageFile=File(imagePath);

    await showDialog(
      context: context, 
      builder: (context)=>AlertDialog(
        title: Text(photoList[index].name),
        content: Image.file(
          imageFile,
          cacheHeight: 450,
        ),
        actions: [
          ElevatedButton(
            onPressed: ()=>Navigator.pop(context), 
            child: Text('close'.tr)
          )
        ],
      )
    );
    imageCache.clear();
  }

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
    if(context.mounted) showErrWarnDialog(context, "archiveFinish".tr, "${'archiveFinishContent'.tr}${groupByToString(groupBy.value)}${'archiveFinishContentEnd'.tr}");
  }

 void groupHandler({GroupBy? groupBy}){
    groupBy = groupBy ?? this.groupBy.value;
    final Map<String, List<PhotoData>> grouped = {};
    for (var photo in photoList) {
      DateTime photoDate = DateTime(photo.year, photo.month, photo.day);
      String key;
      switch (groupBy) {
        case GroupBy.year:
          key=DateFormat.y(lang.value.locale.languageCode).format(photoDate);
          break;
        case GroupBy.month:
          key=DateFormat.yMMM(lang.value.locale.languageCode).format(photoDate);
          break;
        case GroupBy.day:
          key=DateFormat.yMMMd(lang.value.locale.languageCode).format(photoDate);
          break;
      }
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(photo);
    }
    var sortedKeys = grouped.keys.toList()..sort();
    groupedData.value={ for (var k in sortedKeys) k: grouped[k]! };
  }

  void closeDir(){
    dir.value="";
    photoList.value=[];
    selectedKey.value=0;
  }

  static Future<void> isolateScan(List args) async {
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

  Future<void> stopScan() async {
    if(isolate!=null){
      isolate?.kill(priority: Isolate.immediate);
      isolate=null;
    }
    loading.value=false;
    dir.value="";
  }

  Future<void> analyseDir(String dir, BuildContext context) async {
    final receivePort = ReceivePort();
    late final StreamSubscription sub;
    loading.value=true;
    try {
      isolate = await Isolate.spawn(isolateScan, [dir, receivePort.sendPort]);
    } catch (e) {
      loading.value = false;
      receivePort.close();
      return;
    }
    final completer = Completer<void>();
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
            groupHandler();
            sub.cancel();
            receivePort.close();
            isolate?.kill(priority: Isolate.immediate);
            completer.complete();
            break;
        }
      }
    });

    await completer.future;
    receivePort.close();
    sub.cancel();
    final context = navigatorKey.currentContext;
    if(photoList.isEmpty){
      if(context!=null && context.mounted){
        await showErrWarnDialog(
          context, 
          "cantAnalyze".tr, 
          "cantAnalyzeContent".tr
        );
      }
    }else{
      this.dir.value=dir;
    }
    loading.value = false;
  }

  Future<void> initLang() async {
    prefs=await SharedPreferences.getInstance();

    int? langIndex=prefs.getInt("langIndex");

    if(langIndex==null){
      final deviceLocale=PlatformDispatcher.instance.locale;
      final local=Locale(deviceLocale.languageCode, deviceLocale.countryCode);
      int index=supportedLocales.indexWhere((element) => element.locale==local);
      if(index!=-1){
        lang.value=supportedLocales[index];
        lang.refresh();
      }
    }else{
      lang.value=supportedLocales[langIndex];
    }
  }

  void changeLanguage(int index){
    lang.value=supportedLocales[index];
    prefs.setInt("langIndex", index);
    lang.refresh();
    Get.updateLocale(lang.value.locale);
  }
}