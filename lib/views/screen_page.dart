

import 'package:billboard/controllers/screen_controller.dart';
import 'package:billboard/views/base_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class ScreenPage extends BaseView<ScreenController> {

  const ScreenPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint("ScreenPage build");
    debugPrint("ScreenPage initialized ${controller.initialized}");
    debugPrint("ScreenPage isClosed ${controller.isClosed}");
    return Obx( () {
      if (controller.videoPlayerController.value?.value.isInitialized == true) {
        return AspectRatio (
          aspectRatio: controller.videoPlayerController.value!.value.aspectRatio,
          child: VideoPlayer(controller.videoPlayerController.value!!),
        );
      } else {
       return const Center(child: CircularProgressIndicator()); 
      }
    }, );
    /*
    return controller.videoPlayerController.value.isInitialized 
      ? 
      AspectRatio (
        aspectRatio: controller.videoPlayerController.value.aspectRatio,
        child: VideoPlayer(controller.videoPlayerController),
      ) 
      : 
      const Center(child: CircularProgressIndicator());
    */
  }
}