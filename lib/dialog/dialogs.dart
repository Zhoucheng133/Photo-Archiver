import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:photo_archiver/controllers/controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showErrWarnDialog(BuildContext context, String title, String content) async {
  await showDialog(
    context: context, 
    builder: (context)=>AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        ElevatedButton(
          onPressed: ()=>Navigator.pop(context), 
          child: Text('ok'.tr)
        )
      ],
    )
  );
}

Future<void> showAbout(BuildContext context) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final version=packageInfo.version;
  if(context.mounted){
    showDialog(
      context: context, 
      builder: (context)=>AlertDialog(
        title: Text('about'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 10,),
            Text(
              'Photo-Archiver',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 3,),
            Text(
              "v$version",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[400]
              ),
            ),
            const SizedBox(height: 20,),
            GestureDetector(
              onTap: () async {
                final Uri url = Uri.parse('https://github.com/Zhoucheng133/Photo-Archiver');
                await launchUrl(url);
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.github,
                      size: 15,
                    ),
                    const SizedBox(width: 5,),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        'prjLink'.tr,
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: () => showLicensePage(
                applicationName: 'Photo-Archiver',
                applicationVersion: 'v$version',
                context: context
              ),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.certificate,
                      size: 15,
                    ),
                    const SizedBox(width: 5,),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        'license'.tr,
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: (){
              Navigator.pop(context);
            }, 
            child: Text('ok'.tr)
          )
        ],
      ),
    );
  }
}

Future<void> showLanguageDialog(BuildContext context) async {
  final controller = Get.find<Controller>();
  await showDialog(
    context: context, 
    builder: (context)=>AlertDialog(
      title: Text('language'.tr),
      content: Obx(()=>DropdownButtonHideUnderline(
        child: DropdownButton(
          isDense: true,
          padding: .all(10),
          borderRadius: .circular(10),
          focusColor: Colors.transparent,
          items: supportedLocales.map((item)=>DropdownMenuItem(
            value: item.locale,
            child: Text(item.name)
          )).toList(),
          value: controller.lang.value.locale,
          onChanged: (value) => controller.changeLanguage(
            supportedLocales.indexWhere((item)=>item.locale == value)
          ),
        )
      )),
      actions: [
        ElevatedButton(
          onPressed: ()=>Navigator.of(context).pop(), 
          child: Text("ok".tr)
        )
      ],
    ),
  );
}

void darkModePanel(BuildContext context){
  final controller = Get.find<Controller>();

  bool tmpDarkMode=controller.dark.value;
  bool tmpAutoDark=controller.autoDark.value;

  showDialog(
    context: context, 
    builder: (context)=>AlertDialog(
      title: Text('darkMode'.tr),
      content: SizedBox(
        width: 200,
        child: Obx(()=>
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 150,
                    child: Text('followSystem'.tr)
                  ),
                  const SizedBox(width: 10,),
                  Expanded(child: Container(height: 10,)),
                  Transform.scale(
                    scale: 0.7,
                    child: Switch(
                      mouseCursor: SystemMouseCursors.basic,
                      splashRadius: 0,
                      value: controller.autoDark.value, 
                      onChanged: (val) async {
                        controller.autoDark.value=val;
                        if(val){
                          final Brightness brightness = MediaQuery.of(context).platformBrightness;
                          if(brightness == Brightness.dark){
                            controller.dark.value=true;
                          }else{
                            controller.dark.value=false;
                          }
                        }
                      }
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: 150,
                    child: Text('enableDark'.tr)
                  ),
                  const SizedBox(width: 10,),
                  Expanded(child: Container(height: 10,)),
                  Transform.scale(
                    scale: 0.7,
                    child: Switch(
                      mouseCursor: SystemMouseCursors.basic,
                      splashRadius: 0,
                      value: controller.dark.value, 
                      onChanged: controller.autoDark.value ? null : (val) async {
                        controller.dark.value=val;
                      }
                    ),
                  )
                ],
              ),
            ],
          )
        ),
      ),
      actions: [
        TextButton(
          onPressed: (){
            Navigator.pop(context);
            controller.dark.value=tmpDarkMode;
            controller.autoDark.value=tmpAutoDark;
          }, 
          child: Text('cancel'.tr)
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            final prefs=await SharedPreferences.getInstance();
            prefs.setBool('dark', controller.dark.value);
            prefs.setBool('autoDark', controller.autoDark.value);
          }, 
          child: Text('ok'.tr)
        )
      ],
    )
  );
}