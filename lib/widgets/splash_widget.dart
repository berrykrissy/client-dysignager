import 'package:billboard/controllers/splash_controller.dart';
import 'package:billboard/widgets/base_widgets.dart';
import 'package:flutter/material.dart';

class SplashWidget extends BaseWidget<SplashController> {
  
  const SplashWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
      color: Colors.white,
      child: Align(alignment: Alignment.center,
      child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/DYSIGNAGER.webp"),
        ],
      ),),
    ),
    );
  } 
}