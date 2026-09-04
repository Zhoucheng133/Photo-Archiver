import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:photo_archiver/controllers/handler.dart';

void showPhotoPreview(BuildContext context, String filePath, PhotoData photo) {
  final String unknownStr = "unknown".tr;
  final String countryStr = photo.country.isEmpty ? unknownStr : photo.country;
  final String cityStr = photo.city.isEmpty ? unknownStr : photo.city;

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
                  return Text(
                    "unableToLoad".tr,
                    style: const TextStyle(color: Colors.white),
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
                "${photo.name} (${photo.getDate()} | $countryStr $cityStr)",
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