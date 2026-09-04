import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:photo_archiver/controllers/controller.dart';
import 'package:photo_archiver/controllers/handler.dart';
import 'package:photo_archiver/lang/en_us.dart';
import 'package:photo_archiver/lang/zh_cn.dart';
import 'package:photo_archiver/lang/zh_tw.dart';
import 'package:photo_archiver/main_window.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(800, 600),
    minimumSize: Size(800, 600),
    title: "PhotoArchiver",
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  final controller=Get.put(Controller());
  Get.put(Handler());
  await controller.init();

  runApp(const MainApp());
}

class MainTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': enUS,
    'zh_CN': zhCN,
    'zh_TW': zhTW,
  };
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {

    final controller=Get.find<Controller>();
    bool platformDarkMode=MediaQuery.of(context).platformBrightness==Brightness.dark;
    controller.darkModeHandler(platformDarkMode);

    return Obx(
      ()=> GetMaterialApp(
        translations: MainTranslations(), 
        theme: ThemeData(
          brightness: controller.dark.value ? Brightness.dark : Brightness.light,
          fontFamily: 'PuHui', 
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.lime,
            brightness: controller.dark.value ? Brightness.dark : Brightness.light,
          ),
          textTheme: controller.dark.value ? ThemeData.dark().textTheme.apply(
            fontFamily: 'PuHui',
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ) : ThemeData.light().textTheme.apply(
            fontFamily: 'PuHui',
          ),
        ),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        locale: controller.lang.value.locale, 
        supportedLocales: supportedLocales.map((item)=>item.locale).toList(),
        fallbackLocale: supportedLocales[0].locale,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: MainWindow()
        ),
      ),
    );
  }
}
