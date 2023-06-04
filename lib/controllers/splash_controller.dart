import 'dart:async';
import 'package:billboard/controllers/base_controller.dart';
import 'package:billboard/routes/app_pages.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class SplashController extends BaseController {

  late Timer _timer;

  @override
  void onInit() {
    super.onInit();
    debugPrint("SplashController onInit");
  }

  @override
  void onReady() {
    super.onReady();
    debugPrint("SplashController onReady");
    _startTimer();
  }

  void _startTimer() {
    debugPrint("SplashController startTimer");
    _timer = Timer(const Duration(milliseconds: 10000), (() => _launchScreen()));
  }

  void _launchScreen() {
      debugPrint("SplashController Timer Stops");
      Get.offAndToNamed(Routes.SCREEN);
      _timer.cancel();
  }

  @override
  void onClose() {
    debugPrint("SplashController onClose");
    super.onClose();
  }
}