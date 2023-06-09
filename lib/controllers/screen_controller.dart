import 'dart:async';
import 'package:billboard/controllers/base_controller.dart';
import 'package:billboard/models/advertisement_model.dart';
import 'package:billboard/models/locations_model.dart';
import 'package:billboard/services/firestore/firestore_service.dart';
import 'package:billboard/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class ScreenController extends BaseController {
  
  ScreenController(FirestoreService this._dbService) {
    debugPrint("ScreenController Constructor");
  }

  final FirestoreService _dbService;
  final advertisements = <AdvertisementModel>[].obs;
  int index = 0;

  RxBool isVideo = false.obs;
  late VideoPlayerController? videoPlayerController;

  @override
  Future<void> onInit() async {
    super.onInit();
    debugPrint("ScreenController onInit");
    //setVideo('assets/video.mp4');
    _updateLocation("LvreLbzIGD1MlR2yQyPq", Constants.ONLINE);
    _getAdvertisements();
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("GPS", "Location services are disabled. Please enable the services");
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar("GPS", "Location permissions are denied");
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Get.snackbar("GPS", "Location permissions are permanently denied, we cannot request permissions.");
      return false;
    }
    return true;
  }

  Future<void> _updateLocation(String id, String status) async {
    if (await _handleLocationPermission()) {
      Position position = await Geolocator.getCurrentPosition (
          desiredAccuracy: LocationAccuracy.high);
      _dbService.updateLocation (
        id, 
        LocationsModel (
          name: "Manila",
          address: "HXRM+4G Manila, Metro Manila",
          gps: GeoPoint(position.latitude ,position.longitude),
          onlineSince: DateTime.now().toString(),
          status: status,
        ).toMap()
      );  
    }
  }

  void setVideo(String source) {
    debugPrint("ScreenController setVideo($source)");
    videoPlayerController = VideoPlayerController.asset(source);
    videoPlayerController
      ?..addListener(() {
        debugPrint(
            "ScreenController Listener isInitialized ${videoPlayerController?.value.isInitialized}");
        debugPrint(
            "ScreenController Listener isPlaying ${videoPlayerController?.value.isPlaying}");
        debugPrint(
            "ScreenController Listener duration  ${videoPlayerController?.value.duration}");
        debugPrint(
            "ScreenController Listener position ${videoPlayerController?.value.position}");
        if (videoPlayerController?.value.isInitialized == true &&
            videoPlayerController?.value.isPlaying == false &&
            videoPlayerController?.value.position ==
                videoPlayerController?.value.duration) {
          debugPrint("ScreenController Listener duration isVideo(false)");
          isVideo(false);
        } else {
          debugPrint("ScreenController Listener duration isVideo(true)");
          isVideo(true);
        }
      })
      ..setLooping(false)
      ..initialize().then(
        (value) {
          debugPrint(
              "ScreenController initialize ${videoPlayerController?.value}");
          return videoPlayerController?.play();
        },
      );
  }

  bool isVieoMuted() {
    return videoPlayerController?.value.volume == 0;
  }

  RxBool observeIsVideo() {
    return isVideo;
  }
  
  Future<void> _getAdvertisements() async {
    final snapshot = await _dbService.getAdvertisement();
    for (final item in snapshot) {
      advertisements.add(item);
    }
    debugPrint("ScreenController _getAdvertisements ${advertisements.length}");
    index = 0;
    Timer.periodic (
      const Duration(seconds: 1), (timer) {
        debugPrint("ScreenController tick ${timer.tick}");
        if (timer.tick % 5 == 0) {
          index++;
          debugPrint("ScreenController tick timer.tick % 30 == 0 index $index");
        }
        if (advertisements.length - 1 < index) {
          index = 0;
        }
        debugPrint("ScreenController index ${index} advertisement ${advertisements.value[index].duration} ${advertisements.value[index].mediaType} ${advertisements.value[index].mediaUrl}");
      }
    );
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    debugPrint("ScreenController onReady");
  }

  @override
  void onClose() {
    super.onClose();
    debugPrint("ScreenController onClose");
    videoPlayerController?.dispose();
    _updateLocation("LvreLbzIGD1MlR2yQyPq", Constants.OFFLINE);
  }
}
