import 'package:billboard/controllers/base_controller.dart';
import 'package:billboard/models/marker_model.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class ScreenController extends BaseController {

  @override
  Future<void> onInit() async {
    super.onInit();
    debugPrint("ScreenController onInit");
    debugPrint("ScreenController GetCoordinates() ${await _GetCoordinates()}");
    //TODO Send Coordinates to Admin and Send Status 
  }

   Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("GPS","Location services are disabled. Please enable the services");
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {   
        Get.snackbar("GPS","Location permissions are denied");
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Get.snackbar("GPS","Location permissions are permanently denied, we cannot request permissions.");
      return false;
    }
    return true;
  }

  Future<MarkerModel?> _GetCoordinates() async {
    if(await _handleLocationPermission()) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      return MarkerModel(latitude: position.latitude, longitude: position.longitude);
    } else {
      return null;
    }
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