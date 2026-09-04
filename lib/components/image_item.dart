import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_archiver/components/preview.dart';
import 'package:photo_archiver/controllers/handler.dart';

class ImageItem extends StatefulWidget {

  final PhotoData photoData;
  final String filePath;

  const ImageItem({super.key, required this.photoData, required this.filePath});

  @override
  State<ImageItem> createState() => _ImageItemState();
}

class _ImageItemState extends State<ImageItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showPhotoPreview(context, widget.filePath, widget.photoData),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Theme.of(context).dividerColor.withAlpha(80),
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
                  File(widget.filePath),
                  fit: BoxFit.cover,
                  cacheHeight: 200,
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
                widget.photoData.name,
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
  }
}