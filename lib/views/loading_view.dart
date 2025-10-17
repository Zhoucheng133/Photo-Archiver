import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_archiver/controllers/controller.dart';

class LoadingView extends StatefulWidget {
  const LoadingView({super.key});

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {

  final Controller controller=Get.find();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 10,),
          Obx(()=>Text("正在扫描: ${controller.nowFile.value}")),
          const SizedBox(height: 20,),
          ElevatedButton(
            onPressed: (){
              controller.stopScan();
            }, 
            child: const Text('停止扫描')
          )
        ],
      ),
    );
  }
}