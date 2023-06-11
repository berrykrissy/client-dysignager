import 'dart:async';
import 'package:billboard/controllers/base_controller.dart';
import 'package:billboard/models/advertisement_model.dart';
import 'package:billboard/models/locations_model.dart';
import 'package:billboard/services/firestore/firestore_service.dart';
import 'package:billboard/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
//import 'package:mac_address/mac_address.dart';
import 'package:video_player/video_player.dart';

class ScreenController extends BaseController {
  
  ScreenController(FirestoreService this._service) {
    debugPrint("ScreenController Constructor");
  }

  final FirestoreService _service;
  final advertisements = <AdvertisementModel>[].obs;
  LocationsModel? _locations = null;
  PageController pageController = new PageController(initialPage: 0);

  int index = 0;
 
  final RxBool isLoading = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    debugPrint("ScreenController onInit mac address");
    //debugPrint("ScreenController mac address "); TODO: Mac Address Still can't get
    getLocation();
    _handleLocationPermission();
    //setVideo('assets/video.mp4');
    _getAdvertisements();
  }

  Future<void> getLocation() async {
    debugPrint("ScreenController getLocation");
    final snapshot = await _service.getLocationsByIdByCity("Manila");
    _locations = snapshot.firstOrNull;
    debugPrint("ScreenController getLocation $_locations");
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

  Future<void> _updateLocation(String status) async {
    //TODO GPS Still Can't Get
    debugPrint("ScreenController _updateLocation $status ${await _handleLocationPermission()}");
    debugPrint("ScreenController isLocationServiceEnabled ${await Geolocator.isLocationServiceEnabled()}");
    /*
    if (await _handleLocationPermission()) {
      Position position = await Geolocator.getCurrentPosition ( desiredAccuracy: LocationAccuracy.best);
      _service.updateLocation (
        _locations?.id, 
        LocationsModel (
          name: _locations?.name,
          address: _locations?.address,
          gps: GeoPoint(position.latitude ,position.longitude),
          onlineSince: DateTime.now().toString(),
          status: status,
        ).toMap()
      );
    } else {
      _service.updateLocation (
        _locations?.id, 
        LocationsModel (
          name: _locations?.name,
          address: _locations?.address,
          gps: _locations?.gps,
          onlineSince: DateTime.now().toString(),
          status: status,
        ).toMap()
      );
    }
    */
  }

  VideoPlayerController getVideoNetwork(RxBool isVideoLoading, String source) {
    debugPrint("ScreenController getVideoNetwork($source)");
    final videoPlayerController = VideoPlayerController.network(source); //VideoPlayerController.asset(source);
    videoPlayerController?..addListener( () {
      debugPrint("ScreenController Listener isInitialized ${videoPlayerController?.value.isInitialized}");
      debugPrint("ScreenController Listener isPlaying ${videoPlayerController?.value.isPlaying}");
      debugPrint("ScreenController Listener duration  ${videoPlayerController?.value.duration}");
      debugPrint("ScreenController Listener position ${videoPlayerController?.value.position}");
      if (videoPlayerController?.value.isInitialized == true &&
        videoPlayerController?.value.isPlaying == false &&
        videoPlayerController?.value.position ==
        videoPlayerController?.value.duration) {
        debugPrint("ScreenController Listener duration isVideo(false)");
        isVideoLoading(true);
        _nextAdvertisement();
      } else {
        debugPrint("ScreenController Listener duration isVideo(true)");
        isVideoLoading(false);
      }
    } )
    ..setLooping(false)
    ..initialize().then( (value) {
        debugPrint("ScreenController initialize ${videoPlayerController?.value}");
        isVideoLoading(true);
        isVideoLoading(false);
        return videoPlayerController?.play();
      },
    );
    return videoPlayerController;
  }
  
  Future<void> _getAdvertisements() async {
    debugPrint("ScreenController _getAdvertisements()"); 
    isLoading(true);
    advertisements.clear();
    final snapshot = await _service.getAdvertisement();
    for (final item in snapshot) {
      if (item.mediaType?.toLowerCase()?.contains("mp4") == true) {
        item.isVideoLoading = false.obs;
        item.videoPlayerController = getVideoNetwork(item.isVideoLoading!, item.mediaUrl!);
        advertisements.add(item);
      } else {
        advertisements.add(item);
      }
      
    }
    debugPrint("ScreenController _getAdvertisements ${advertisements.length}");
    debugPrint("ScreenController _getAdvertisements ${advertisements}"); 
    index = 0;
    Timer.periodic (
      const Duration(seconds: 30), (timer) {
        debugPrint("ScreenController tick ${timer.tick}");
        _updateLocation(Constants.ONLINE);
        /*
        if (timer.tick % 30 == 0) {
          index++;
          debugPrint("ScreenController tick timer.tick % 30 == 0 index $index");
        }
        */
        _nextAdvertisement();
      }
    );
    isLoading(false);
  }

  Future<void> _nextAdvertisement() async {
    debugPrint("ScreenController _nextAdvertisement()");
    advertisements.value[index].videoPlayerController?.pause();
    if (advertisements.length - 1 < index) {
      index = 0;
    }
    if (advertisements.value[index].mediaType?.toLowerCase()?.contains("jpg") == true || advertisements.value[index].mediaType?.contains("png") == true || advertisements.value[index].mediaType?.toLowerCase()?.contains("webp") == true) {
      debugPrint("ScreenController _nextAdvertisement() is Image");
    } else {
      debugPrint("ScreenController _nextAdvertisement() is Video");
      //videoPlayerController?.dispose;  
      advertisements.value[index].videoPlayerController?.initialize();
      advertisements.value[index].videoPlayerController?.play();
    }
    debugPrint("ScreenController index ${index} advertisement ${advertisements.value[index].duration} ${advertisements.value[index].mediaType} ${advertisements.value[index].mediaUrl}");
    pageController.jumpToPage(index);
    index++;
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    debugPrint("ScreenController onReady");
    //NetWorkInfo netWorkInfo = NetworkInfo();
    //debugPrint("ScreenController MAC Address ${await }");
    _updateLocation(Constants.ONLINE);
  }

  @override
  void onClose() {
    super.onClose();
    debugPrint("ScreenController onClose");
    advertisements.map( (element) {
      element.videoPlayerController?.dispose();
    } );
    _updateLocation(Constants.OFFLINE);
  }
}