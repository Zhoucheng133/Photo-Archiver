import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_archiver/controllers/handler.dart';

class LoadingView extends StatefulWidget {
  const LoadingView({super.key});

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {

  final Handler handler=Get.find();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: .min,
        spacing: 5,
        children: [
          CircularProgressIndicator(),
          Obx(()=>Text("read".tr+handler.nowFile.value),)
        ],
      ),
    );
  }
}