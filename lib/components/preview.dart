import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_archiver/controllers/handler.dart';

/// 获取图片的原始像素尺寸
Future<Size> _getImageSize(File file) {
  final completer = Completer<Size>();
  final imageProvider = FileImage(file);
  final stream = imageProvider.resolve(const ImageConfiguration());
  late ImageStreamListener listener;
  listener = ImageStreamListener(
    (ImageInfo info, bool _) {
      completer.complete(
        Size(info.image.width.toDouble(), info.image.height.toDouble()),
      );
      stream.removeListener(listener);
    },
    onError: (Object error, StackTrace? stackTrace) {
      completer.completeError(error, stackTrace);
      stream.removeListener(listener);
    },
  );
  stream.addListener(listener);
  return completer.future;
}

Future<void> showPhotoPreview(BuildContext context, String filePath, PhotoData photo) async {
  final file = File(filePath);
  Size? imageSize;
  try {
    imageSize = await _getImageSize(file);
  } catch (_) {
    imageSize = null;
  }

  if (!context.mounted) return;

  await showDialog(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(30),
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          double height = constraints.maxHeight;

          if (imageSize != null && imageSize.width > 0 && imageSize.height > 0) {
            final imageAspect = imageSize.width / imageSize.height;
            final boxAspect = constraints.maxWidth / constraints.maxHeight;

            if (imageAspect > boxAspect) {
              // 图片更"宽" -> 以可用宽度为准，竖图会自然变窄变高
              width = constraints.maxWidth;
              height = width / imageAspect;
            } else {
              // 图片更"高"（竖图）-> 以可用高度为准
              height = constraints.maxHeight;
              width = height * imageAspect;
            }
          }

          return SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    child: Image.file(
                      file,
                      fit: BoxFit.contain,
                      cacheHeight: 500,
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
                Positioned(
                  top: 16,
                  right: 16,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(150),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "${photo.name} (${photo.getDate()} | ${locationString(photo)})",
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const FaIcon(
                              FontAwesomeIcons.xmark,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}