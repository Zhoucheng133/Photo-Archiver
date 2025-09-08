import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_archiver/controllers/controller.dart';
import 'package:photo_archiver/main_window.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(800, 600),
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

  Get.put(Controller());

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return MaterialApp(
      theme: brightness==Brightness.dark ? ThemeData.dark().copyWith(
        textTheme: GoogleFonts.notoSansScTextTheme().apply(
          bodyColor: Colors.white,
          displayColor: Colors.white, 
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lime,
          brightness: Brightness.dark,
        ),
      ) : ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lime),
        textTheme: GoogleFonts.notoSansScTextTheme(),
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: MainWindow()
      ),
    );
  }
}
