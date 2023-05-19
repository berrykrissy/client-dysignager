import 'package:billboard/controllers/base_controller.dart';
import 'package:flutter/foundation.dart';

class ScreenController extends BaseController {

  @override
  void onInit() {
    super.onInit();
    debugPrint("ScreenController onInit");
  }

  @override
  void onReady() {
    super.onReady();
    debugPrint("ScreenController onReady");
  }

  @override
  void onClose() {
    debugPrint("ScreenController onClose");
    super.onClose();
  }
}