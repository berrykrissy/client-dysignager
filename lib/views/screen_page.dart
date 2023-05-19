

import 'package:billboard/controllers/screen_controller.dart';
import 'package:billboard/views/base_view.dart';
import 'package:flutter/material.dart';

class ScreenPage extends BaseView<ScreenController> {

  const ScreenPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint("ScreenPage build");
    debugPrint("ScreenPage initialized ${controller.initialized}");
    debugPrint("ScreenPage isClosed ${controller.isClosed}");
    return const Center(child: CircularProgressIndicator());
  }
}