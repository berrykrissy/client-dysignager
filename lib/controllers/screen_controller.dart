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
import "package:universal_html/html.dart" as html;
import 'package:video_player/video_player.dart';

class ScreenController extends BaseController {
  
  ScreenController(FirestoreService this._service, arguments) {
    debugPrint("ScreenController Constructor");
    _locations = arguments;
  }

  final FirestoreService _service;
  final advertisements = <AdvertisementModel>[].obs;
  LocationsModel? _locations;
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
    _getAdvertisements();
    pageController.addListener(() {
      debugPrint("ScreenController pageController page ${pageController.page}");
      final isPageNotNull = pageController.page?.toInt() != null;
      final past = pageController.page!.toInt() - 1;
      if (isPageNotNull && -1 < past ) {
        debugPrint("ScreenController pageController pause $past");
        advertisements.value[advertisements.length - 1].videoPlayerController?.pause();
      } else if (isPageNotNull) {
        debugPrint("ScreenController pageController pause ${advertisements.length - 1}");
        advertisements.value[advertisements.length - 1].videoPlayerController?.pause();
      }
      final present = pageController.page!.toInt();
      if (isPageNotNull && present < advertisements.length) {
        debugPrint("ScreenController pageController play $present ${advertisements.value[present].mediaType}");
        advertisements.value[present].videoPlayerController?.play();
      } else if (isPageNotNull && advertisements.isNotEmpty) {
        debugPrint("ScreenController pageController play 0 ${advertisements.value[0].mediaType}");
        advertisements.value[0].videoPlayerController?.play();
      }
      final future = pageController.page!.toInt() + 1;
      if (isPageNotNull && future < advertisements.length) {
        debugPrint("ScreenController pageController initialize $future");
        advertisements.value[future].videoPlayerController?.initialize();
      } else if (isPageNotNull && advertisements.isNotEmpty) {
        debugPrint("ScreenController pageController initialize 0");
        advertisements.value[0].videoPlayerController?.initialize();
      }
    });
    html.window.onBeforeUnload.listen((event) async {
        debugPrint("ScreenController onBeforeUnload ${event}");
        _updateLocation(Constants.OFFLINE);
      });
    html.window.onUnload.listen((event) async {
      debugPrint("ScreenController onUnload ${event}");
      advertisements.map( (element) {
        element.videoPlayerController?.dispose();
      } );
    });
  }

  void onRefresh() {
    Timer (
      const Duration(milliseconds: 3000), ( () => html.window.location.reload() )
    );
  }

  void onShowAlert(String title, String message) {
    Timer(
      const Duration(milliseconds: 2000), ( () => Get.snackbar(title, message) )
    );
  }

  Future<void> getLocation() async {
    debugPrint("ScreenController getLocation");
    final snapshot = await _service.getLocationsByIdByCity(Constants.CITY);
    _locations = snapshot.firstOrNull;
    debugPrint("ScreenController getLocation $_locations");
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

  Future<void> _updateLocation(String status) async {
    //TODO GPS Still Can't Get in Rasbian OS
    debugPrint("ScreenController _updateLocation $status");
    //debugPrint("ScreenController _handleLocationPermission ${await _handleLocationPermission()} isLocationServiceEnabled ${await Geolocator.isLocationServiceEnabled()}");
    if (await _handleLocationPermission()) {
      Position position = await Geolocator.getCurrentPosition ( desiredAccuracy: LocationAccuracy.best);
      //debugPrint("ScreenController isLocationServiceEnabled ${position.latitude} ${position.longitude}");
      //debugPrint("ScreenController DateTime.now() ${DateTime.now()}");
      _service.updateLocation (
        _locations?.id, 
        LocationsModel (
          name: _locations?.name,
          address: _locations?.address,
          gps: GeoPoint(position.latitude ,position.longitude),
          onlineSince: DateTime.now(),
          status: status,
          isEnabled: _locations?.isEnabled,
        ).toMap()
      );
    } else {
      _service.updateLocation (
        _locations?.id, 
        LocationsModel (
          name: _locations?.name,
          address: _locations?.address,
          gps: _locations?.gps,
          onlineSince: DateTime.now(),
          status: status,
          isEnabled: _locations?.isEnabled,
        ).toMap()
      );
    }
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
        //isVideoLoading(true);
        //isVideoLoading(false);
        //return videoPlayerController?.play();
      },
    );
    return videoPlayerController;
  }
  
  Future<void> _getAdvertisements() async {
    debugPrint("ScreenController _getAdvertisements() ${_locations?.isEnabled == true}"); 
    isLoading(true);
    if (_locations?.isEnabled == true || (await _service.getLocationsByIdByCity(Constants.CITY)).firstOrNull?.isEnabled == true) {
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
      _startAdvertisement();
    } else {
      onShowAlert("Status Disabled", "This is disabled Can't show ads");
    }
    isLoading(false);
  }

  Future<void> _startAdvertisement() async {
    debugPrint("ScreenController _startAdvertisement ${advertisements.length}");
    debugPrint("ScreenController _startAdvertisement ${advertisements}"); 
    index = 0;
    Timer.periodic (
      const Duration(seconds: 30), (timer) {
        debugPrint("ScreenController tick ${timer.tick}");
        _checkStatus();
        _nextAdvertisement();
      }
    );
  }

  Future<void> _nextAdvertisement() async {
    debugPrint("ScreenController _nextAdvertisement()");
    debugPrint("ScreenController index ${index} advertisement ${advertisements.value[index].duration} ${advertisements.value[index].mediaType} ${advertisements.value[index].mediaUrl}");
    pageController.jumpToPage(index);
    if (index < advertisements.length - 1) {
      index++;
    } else {
      index = 0;
    }
  }

  Future<void> _checkStatus() async {
    final snapshot = await _service.getAdvertisement();
    final isSizeSame = snapshot.length == advertisements.length;
    bool? sameContents = null;
    for (var newItem in snapshot) { 
      if (!isSizeSame || advertisements.where((oldItem) => oldItem.mediaUrl == newItem.mediaUrl ).isEmpty) {
        sameContents = false;
        break;
      } else {
        sameContents = true;
      }
    }
    debugPrint("ScreenController _checkStatus isSizeSame $isSizeSame sameContents $sameContents");
    if (isSizeSame && sameContents == true) {
      _updateLocation(Constants.ONLINE);
    } else {
      _updateLocation(Constants.OUT_OF_SYNC);
      onRefresh();
    }
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
  Future<void> onClose() async {
    super.onClose();
    debugPrint("ScreenController onClose");
    advertisements.map( (element) {
      element.videoPlayerController?.dispose();
    } );
    _updateLocation(Constants.OFFLINE);
  }
}