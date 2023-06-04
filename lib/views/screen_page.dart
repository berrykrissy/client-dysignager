import 'package:billboard/controllers/screen_controller.dart';
import 'package:billboard/views/base_view.dart';
import 'package:billboard/widgets/video_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScreenPage extends BaseView<ScreenController> {

  const ScreenPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint("ScreenPage build");
    debugPrint("ScreenPage initialized ${controller.initialized}");
    debugPrint("ScreenPage isClosed ${controller.isClosed}");
    return Obx( () {
      if (controller.observeIsVideo().isTrue) {
        return VideoPlayerWidget(videoController: controller.videoPlayerController,);
      } else {
       return Image.asset("assets/image.jpg");
      }
    }, );
  }
}