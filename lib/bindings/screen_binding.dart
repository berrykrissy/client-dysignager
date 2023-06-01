import 'package:billboard/bindings/base_binding.dart';
import 'package:billboard/controllers/screen_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class ScreenBinding extends BaseBinding {

  @override
  void dependencies() {
    debugPrint("SplashBinding dependencies");
    Get.lazyPut<ScreenController> ( 
      () => ScreenController(
        
      )
    );
  }
}