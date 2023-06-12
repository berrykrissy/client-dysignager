import 'dart:async';
import 'package:billboard/controllers/base_controller.dart';
import 'package:billboard/models/locations_model.dart';
import 'package:billboard/routes/app_pages.dart';
import 'package:billboard/services/firestore/firestore_service.dart';
import 'package:billboard/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class SplashController extends BaseController {

  SplashController(FirestoreService this._service) {
    debugPrint("SplashController Constructor");
  }

  late Timer _timer;
  final FirestoreService _service;
  LocationsModel? _locations = null;

  @override
  void onInit() {
    super.onInit();
    debugPrint("SplashController onInit");
    _handleLocationPermission();
    getLocation();
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      onShowAlert("GPS", "Location services are disabled. Please enable the services");
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        onShowAlert("GPS", "Location permissions are denied");
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      onShowAlert("GPS", "Location permissions are permanently denied, we cannot request permissions.");
      return false;
    }
    return true;
  }

  void onShowAlert(String title, String message) {
    Timer(
      const Duration(milliseconds: 2000), ( () => Get.snackbar(title, message) )
    );
  }

  Future<void> getLocation() async {
    debugPrint("SplashController getLocation");
    final snapshot = await _service.getLocationsByIdByCity(Constants.CITY);
    _locations = snapshot.firstOrNull;
  }

  @override
  void onReady() {
    super.onReady();
    debugPrint("SplashController onReady");
    _startTimer();
  }

  void _startTimer() {
    debugPrint("SplashController startTimer");
    _timer = Timer (
      const Duration(milliseconds: 10000), (
        () => _launchScreen()
    ) );
  }

  void _launchScreen() {
      debugPrint("SplashController _launchScreen");
      debugPrint("SplashController _locations $_locations");
      Get.offAndToNamed(Routes.SCREEN, arguments: _locations);
      _timer.cancel();
  }

  @override
  void onClose() {
    debugPrint("SplashController onClose");
    super.onClose();
  }
}