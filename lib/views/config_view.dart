import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:photo_archiver/components/image_item.dart';
import 'package:photo_archiver/controllers/controller.dart';
import 'package:photo_archiver/controllers/handler.dart';
import 'package:photo_archiver/dialog/dialogs.dart';

enum ConfigMode {
  time,
  location,
}

enum TimeLevel {
  ymd, // 年月日
  ym,  // 年月
  y,   // 年
}

enum LocationLevel {
  country, // 按国家分类
  city,    // 按城市分类
}

class ConfigView extends StatefulWidget {
  const ConfigView({super.key});

  @override
  State<ConfigView> createState() => _ConfigViewState();
}

class _ConfigViewState extends State<ConfigView> {
  final Handler handler = Get.find();
  final Controller controller = Get.find();

  ConfigMode configMode = ConfigMode.time;
  TimeLevel timeLevel = TimeLevel.ymd;
  LocationLevel locationLevel = LocationLevel.city;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 260,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor.withAlpha(50),
                ),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 16),
                        tooltip: "backToAdd".tr,
                        onPressed: () {
                          handler.photos.clear();
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "configTitle".tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      Text(
                        "classifyMethod".tr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<ConfigMode>(
                        segments: [
                          ButtonSegment(
                            value: ConfigMode.time,
                            label: Text('time'.tr),
                            icon: const FaIcon(FontAwesomeIcons.clock, size: 12),
                          ),
                          ButtonSegment(
                            value: ConfigMode.location,
                            label: Text('location'.tr),
                            icon: const FaIcon(FontAwesomeIcons.locationDot, size: 12),
                          ),
                        ],
                        selected: {configMode},
                        onSelectionChanged: (Set<ConfigMode> newSelection) {
                          setState(() {
                            configMode = newSelection.first;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      if (configMode == ConfigMode.time) ...[
                        Text(
                          "timeLevel".tr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RadioGroup<TimeLevel>(
                          groupValue: timeLevel,
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                timeLevel = val;
                              });
                            }
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                mouseCursor: SystemMouseCursors.basic,
                                leading: Radio<TimeLevel>(
                                  value: TimeLevel.ymd,
                                  splashRadius: 0,
                                  mouseCursor: SystemMouseCursors.basic,
                                ),
                                onTap: () {
                                  setState(() {
                                    timeLevel = TimeLevel.ymd;
                                  });
                                },
                                title: Text('timeYMD'.tr),
                              ),
                              ListTile(
                                mouseCursor: SystemMouseCursors.basic,
                                leading: Radio<TimeLevel>(
                                  value: TimeLevel.ym,
                                  splashRadius: 0,
                                  mouseCursor: SystemMouseCursors.basic,
                                ),
                                onTap: () {
                                  setState(() {
                                    timeLevel = TimeLevel.ym;
                                  });
                                },
                                title: Text('timeYM'.tr),
                              ),
                              ListTile(
                                mouseCursor: SystemMouseCursors.basic,
                                leading: Radio<TimeLevel>(
                                  value: TimeLevel.y,
                                  splashRadius: 0,
                                  mouseCursor: SystemMouseCursors.basic,
                                ),
                                onTap: () {
                                  setState(() {
                                    timeLevel = TimeLevel.y;
                                  });
                                },
                                title: Text('timeY'.tr),
                              ),
                            ],
                          ),
                        )
                      ] else ...[
                        Text(
                          "locationLevel".tr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RadioGroup(
                          groupValue: locationLevel,
                          onChanged: (val){
                            if(val!=null){
                              setState(() {
                                locationLevel=val;
                              });
                            }
                          }, 
                          child: Column(
                            mainAxisSize: .min,
                            children: [
                              ListTile(
                                mouseCursor: SystemMouseCursors.basic,
                                leading: Radio<LocationLevel>(
                                  value: LocationLevel.city,
                                  splashRadius: 0,
                                  mouseCursor: SystemMouseCursors.basic,
                                ),
                                onTap: () {
                                  setState(() {
                                    locationLevel = LocationLevel.city;
                                  });
                                },
                                title: Text('locationCity'.tr),
                              ),
                              ListTile(
                                mouseCursor: SystemMouseCursors.basic,
                                leading: Radio<LocationLevel>(
                                  value: LocationLevel.country,
                                  splashRadius: 0,
                                  mouseCursor: SystemMouseCursors.basic,
                                ),
                                onTap: () {
                                  setState(() {
                                    locationLevel = LocationLevel.country;
                                  });
                                },
                                title: Text('locationCountry'.tr),
                              ),
                            ],
                          )
                        )
                      ],
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        ArchiveMode? mode = await showArchiveModeDialog(context);
                        if (mode != null) {
                          String? targetDir;
                          if (mode == ArchiveMode.specMove || mode == ArchiveMode.specCopy) {
                            targetDir = await FilePicker.platform.getDirectoryPath();
                            if (targetDir == null) return;
                          }
                          await handler.archivePhotos(
                            mode: mode,
                            configMode: configMode,
                            timeLevel: timeLevel,
                            locationLevel: locationLevel,
                            targetDirectory: targetDir,
                            controller: controller,
                          );
                          if (context.mounted) {
                            showErrWarnDialog(context, "success".tr, "archiveComplete".tr);
                          }
                        }
                      },
                      icon: const FaIcon(FontAwesomeIcons.play, size: 14),
                      label: Text("startArchive".tr),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final photos = handler.photos;
              if (photos.isEmpty) {
                return Center(child: Text("noPhotos".tr));
              }

              final Map<String, List<PhotoData>> groupedMap = {};

              for (var photo in photos) {
                String groupKey = "";
                if (configMode == ConfigMode.time) {
                  switch (timeLevel) {
                    case TimeLevel.y:
                      groupKey = DateFormat.y("${controller.lang.value.locale.languageCode}_${controller.lang.value.locale.countryCode}").format(
                        DateTime(photo.year)
                      );
                      break;
                    case TimeLevel.ym:
                      groupKey = DateFormat.yMMM("${controller.lang.value.locale.languageCode}_${controller.lang.value.locale.countryCode}").format(
                        DateTime(photo.year, photo.month)
                      );
                      break;
                    case TimeLevel.ymd:
                      groupKey = DateFormat.yMMMd("${controller.lang.value.locale.languageCode}_${controller.lang.value.locale.countryCode}").format(
                        DateTime(photo.year, photo.month, photo.day)
                      );
                      break;
                  }
                } else {
                  if (locationLevel == LocationLevel.country) {
                    groupKey = photo.country.isEmpty ? "unkownLocation".tr : photo.country;
                  } else {
                    groupKey = photo.city.isEmpty ? "unkownLocation".tr : photo.city;
                  }
                }

                groupedMap.putIfAbsent(groupKey, () => []).add(photo);
              }

              final sortedKeys = groupedMap.keys.toList()..sort((a, b) {
                final unknownText = "unkownLocation".tr;
                if (configMode == ConfigMode.location) {
                  if (a == unknownText) return 1;
                  if (b == unknownText) return -1;
                }
                return a.compareTo(b);
              });

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortedKeys.length,
                itemBuilder: (context, index) {
                  final groupKey = sortedKeys[index];
                  final groupPhotos = groupedMap[groupKey]!;

                  return Card(
                    clipBehavior: Clip.antiAlias,
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 0,
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      shape: RoundedRectangleBorder(
                        side: BorderSide.none,
                      ),
                      collapsedShape: RoundedRectangleBorder(
                        side: BorderSide.none,
                      ),
                      clipBehavior: Clip.antiAlias,
                      title: Text(
                        groupKey,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        "totalPhotos".trParams({'count': '${groupPhotos.length}'}),
                        style: const TextStyle(fontSize: 12),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 140,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 1,
                            ),
                            itemCount: groupPhotos.length,
                            itemBuilder: (context, photoIndex) {
                              final photo = groupPhotos[photoIndex];
                              final filePath = p.join(photo.dir, photo.name);

                              return ImageItem(photoData: photo, filePath: filePath);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
