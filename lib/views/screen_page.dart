import 'package:billboard/controllers/screen_controller.dart';
import 'package:billboard/views/base_view.dart';
import 'package:billboard/widgets/image_widget.dart';
import 'package:billboard/widgets/page_view_widget.dart';
import 'package:billboard/widgets/video_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScreenPage extends BaseView<ScreenController> with WidgetsBindingObserver {

  const ScreenPage( {
    Key? key
  } ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx ( () {
      if (controller.isLoading.isTrue) {
        return const Center( child: CircularProgressIndicator() );
      } else {
        return PageViewWidget (
          canScroll: true,
          pageController: controller.pageController,
          isLoading: controller.isLoading,
          widgets: controller.advertisements.map((cell) {
            if(cell.mediaType?.toLowerCase().contains("mp4") == true) {
              return VideoPlayerWidget (
                videoController: cell.videoPlayerController,
                isLoading: cell.isVideoLoading,
              );
            } else {
              return ImageWidget(url: cell.mediaUrl);
            }
          } ).toList()
        );
      }
    });
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    debugPrint("ScreenPage didChangeAppLifecycleState");
    if (state == AppLifecycleState.detached) {
      debugPrint("ScreenPage didChangeAppLifecycleState detached");
    } else if (state == AppLifecycleState.paused) {
      debugPrint("ScreenPage didChangeAppLifecycleState paused");
    } else if (state == AppLifecycleState.inactive) {
      debugPrint("ScreenPage didChangeAppLifecycleState inactive");
    } else if (state == AppLifecycleState.resumed) {
      debugPrint("ScreenPage didChangeAppLifecycleState resumed");
    }
  }
}