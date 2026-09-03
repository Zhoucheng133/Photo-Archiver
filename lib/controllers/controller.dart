import 'dart:async';
import 'dart:ui';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ffi';
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

  late SharedPreferences prefs;
  Rx<LanguageType> lang=Rx(supportedLocales[0]);
  // late Rx<DarkMode> darkMode;
  RxBool autoDark=true.obs;
  RxBool dark=false.obs;

  Future<void> init() async {
    prefs=await SharedPreferences.getInstance();

    int? langIndex=prefs.getInt("langIndex");
    autoDark.value=prefs.getBool("autoDark")??true;
    dark.value=prefs.getBool("dark")??false;

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

  void darkModeHandler(bool platformDark){
    if(autoDark.value){
      dark.value=platformDark;
    }
  }

  void changeLanguage(int index){
    lang.value=supportedLocales[index];
    prefs.setInt("langIndex", index);
    lang.refresh();
    Get.updateLocale(lang.value.locale);
  }
}