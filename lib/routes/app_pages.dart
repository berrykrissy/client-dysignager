import 'package:billboard/bindings/screen_binding.dart';
import 'package:billboard/bindings/splash_binding.dart';
import 'package:billboard/views/screen_page.dart';
import 'package:billboard/views/splash_page.dart';
import 'package:get/get.dart';
part 'routes.dart';

abstract class AppPages {
  static final pages = [
    GetPage(
      name: Routes.SPLASH,
      page: () => new SplashPage(),
      binding: SplashBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 3000),
    ),
    GetPage(
      name: Routes.SCREEN,
      page: () => const ScreenPage(),
      binding: ScreenBinding(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 250),
    ),
  ];
}