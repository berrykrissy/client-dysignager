import 'package:billboard/controllers/screen_controller.dart';
import 'package:billboard/views/base_view.dart';
import 'package:billboard/widgets/image_widget.dart';
import 'package:billboard/widgets/video_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScreenPage extends BaseView<ScreenController> {

  const ScreenPage( {
    Key? key
  } ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint("ScreenPage build");
    debugPrint("ScreenPage initialized ${controller.initialized}");
    debugPrint("ScreenPage isClosed ${controller.isClosed}");
    return Obx ( () {
      if (controller.observeLoading().isFalse && controller.observeIsVideo().isTrue) {
        //return Text(controller.url.toString());
        return VideoPlayerWidget (
          videoController: controller.videoPlayerController,
          isLoading: controller.observeLoading(),
        );
      } else if (controller.observeLoading().isFalse && controller.observeIsVideo().isFalse) {
        //return Text(controller.url.toString());
        return ImageWidget (
          url: controller.url.value
        );
      } else {
        return const SizedBox (
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        );
      }
    }, );
  }
}