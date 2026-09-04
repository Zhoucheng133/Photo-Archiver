import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:photo_archiver/controllers/handler.dart';

enum ConfigMode {
  time,
  location,
}

enum TimeLevel {
  ymd, // 年月日
  ym,  // 年月
  y,   // 年
}

class ConfigView extends StatefulWidget {
  const ConfigView({super.key});

  @override
  State<ConfigView> createState() => _ConfigViewState();
}

class _ConfigViewState extends State<ConfigView> {
  final Handler handler = Get.find();

  ConfigMode _configMode = ConfigMode.time;
  TimeLevel _timeLevel = TimeLevel.ymd;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Sidebar for classification configuration
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
                        tooltip: "返回添加页面",
                        onPressed: () {
                          handler.photos.clear();
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "照片归档配置",
                        style: TextStyle(
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
                      const Text(
                        "分类方式",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<ConfigMode>(
                        segments: const [
                          ButtonSegment(
                            value: ConfigMode.time,
                            label: Text('时间'),
                            icon: FaIcon(FontAwesomeIcons.clock, size: 12),
                          ),
                          ButtonSegment(
                            value: ConfigMode.location,
                            label: Text('地点'),
                            icon: FaIcon(FontAwesomeIcons.locationDot, size: 12),
                          ),
                        ],
                        selected: {_configMode},
                        onSelectionChanged: (Set<ConfigMode> newSelection) {
                          setState(() {
                            _configMode = newSelection.first;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      if (_configMode == ConfigMode.time) ...[
                        const Text(
                          "时间粒度",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RadioListTile<TimeLevel>(
                          title: const Text('年月日 (2026/05/07)'),
                          value: TimeLevel.ymd,
                          groupValue: _timeLevel,
                          onChanged: (val) {
                            setState(() {
                              _timeLevel = val!;
                            });
                          },
                        ),
                        RadioListTile<TimeLevel>(
                          title: const Text('年月 (2026/05)'),
                          value: TimeLevel.ym,
                          groupValue: _timeLevel,
                          onChanged: (val) {
                            setState(() {
                              _timeLevel = val!;
                            });
                          },
                        ),
                        RadioListTile<TimeLevel>(
                          title: const Text('年 (2026)'),
                          value: TimeLevel.y,
                          groupValue: _timeLevel,
                          onChanged: (val) {
                            setState(() {
                              _timeLevel = val!;
                            });
                          },
                        ),
                      ] else ...[
                        const Text(
                          "地点层级",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Text(
                            '国家 / 城市 (未知地点归为"未知")',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ),
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
                      onPressed: () {
                        // TODO: Implement execution of organization
                        Get.snackbar("提示", "功能开发中...");
                      },
                      icon: const FaIcon(FontAwesomeIcons.play, size: 14),
                      label: const Text("开始归档"),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Right content area showing classified groups and photo previews
          Expanded(
            child: Obx(() {
              final photos = handler.photos;
              if (photos.isEmpty) {
                return const Center(child: Text("暂无照片数据"));
              }

              // Group photos based on current mode
              final Map<String, List<PhotoData>> groupedMap = {};

              for (var photo in photos) {
                String groupKey = "";
                if (_configMode == ConfigMode.time) {
                  switch (_timeLevel) {
                    case TimeLevel.ymd:
                      groupKey = "${photo.year}/${photo.month.toString().padLeft(2, '0')}/${photo.day.toString().padLeft(2, '0')}";
                      break;
                    case TimeLevel.ym:
                      groupKey = "${photo.year}/${photo.month.toString().padLeft(2, '0')}";
                      break;
                    case TimeLevel.y:
                      groupKey = "${photo.year}";
                      break;
                  }
                } else {
                  String country = photo.country.isEmpty ? "未知" : photo.country;
                  String city = photo.city.isEmpty ? "未知" : photo.city;
                  groupKey = "$country / $city";
                }

                groupedMap.putIfAbsent(groupKey, () => []).add(photo);
              }

              final sortedKeys = groupedMap.keys.toList()..sort();

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortedKeys.length,
                itemBuilder: (context, index) {
                  final groupKey = sortedKeys[index];
                  final groupPhotos = groupedMap[groupKey]!;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      title: Text(
                        groupKey,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        "共 ${groupPhotos.length} 张照片",
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

                              return InkWell(
                                onTap: () {
                                  _showPhotoPreview(context, filePath, photo);
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Theme.of(context).dividerColor,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(5),
                                          ),
                                          child: Image.file(
                                            File(filePath),
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Center(
                                                child: FaIcon(
                                                  FontAwesomeIcons.image,
                                                  color: Colors.grey,
                                                  size: 24,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Text(
                                          photo.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 11),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
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

  void _showPhotoPreview(BuildContext context, String filePath, PhotoData photo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black87,
        insetPadding: const EdgeInsets.all(24),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.file(
                  File(filePath),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      "无法加载图片",
                      style: TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 60,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${photo.name} (${photo.getDate()} | ${photo.country.isEmpty ? '未知' : photo.country} ${photo.city.isEmpty ? '未知' : photo.city})",
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const FaIcon(FontAwesomeIcons.xmark, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
