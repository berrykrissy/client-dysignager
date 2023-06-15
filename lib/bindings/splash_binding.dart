import 'package:billboard/bindings/base_binding.dart';
import 'package:billboard/controllers/splash_controller.dart';
import 'package:billboard/services/firestore/firestore_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class SplashBinding extends BaseBinding {

  @override
  void dependencies() {
    debugPrint("SplashBinding dependencies");
    Get.lazyPut<SplashController> ( 
      () => SplashController(
        Get.find<FirestoreService>(),
      )
    );
  }
}