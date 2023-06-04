import 'dart:async';
import 'package:billboard/controllers/base_controller.dart';
import 'package:billboard/models/marker_model.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as Client;
import 'package:video_player/video_player.dart';

class ScreenController extends BaseController {

  ScreenController() {
    debugPrint("ScreenController Constructor");
  }

  final Client.Socket socket = Client.io("http://localhost:3000");
  RxBool isVideo = false.obs;
  late VideoPlayerController? videoPlayerController;

  @override
  Future<void> onInit() async {
    super.onInit();
    debugPrint("ScreenController onInit");
    debugPrint("ScreenController GetCoordinates() ${await _getCoordinates()}");
    //TODO Send Coordinates to Admin and Send Status
    setVideo('assets/video.mp4');
    socket.on('connect', (data) {
      debugPrint("ScreenController connect");
      socket.emit('msg', 'test');
    } );
    socket.on('event', (data) => debugPrint(data));
    socket.on('disconnect', (disconnect) {
      debugPrint('ScreenController disconnect');
    } );
    socket.on('fromServer', (fromServer) {
      debugPrint('ScreenController $fromServer');
    } );

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

  Future<MarkerModel?> _getCoordinates() async {
    if(await _handleLocationPermission()) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      return MarkerModel(latitude: position.latitude, longitude: position.longitude);
    } else {
      return null;
    }
  }

  void setVideo(String source) {
    debugPrint("ScreenController setVideo($source)");
    videoPlayerController = VideoPlayerController.asset(source);
    videoPlayerController?..addListener( () {
      debugPrint("ScreenController Listener isInitialized ${videoPlayerController?.value.isInitialized}");
      debugPrint("ScreenController Listener isPlaying ${videoPlayerController?.value.isPlaying}");
      debugPrint("ScreenController Listener duration  ${videoPlayerController?.value.duration }");
      debugPrint("ScreenController Listener position ${videoPlayerController?.value.position}");
      if (videoPlayerController?.value.isInitialized == true && videoPlayerController?.value.isPlaying == false && videoPlayerController?.value.position == videoPlayerController?.value.duration) {
        debugPrint("ScreenController Listener duration isVideo(false)");
          isVideo(false);
      } else {
        debugPrint("ScreenController Listener duration isVideo(true)");
          isVideo(true);
      }
    } )
    ..setLooping(false)
    ..initialize().then((value) {
      debugPrint("ScreenController initialize ${videoPlayerController?.value}");
      return videoPlayerController?.play();
    },);
  }

  bool isVieoMuted() {
    return videoPlayerController?.value.volume == 0;
  }

  RxBool observeIsVideo() {
    return isVideo;
  }

  @override
  void onReady() {
    super.onReady();
    debugPrint("ScreenController onReady");
    Timer(Duration(milliseconds: 5000), () {
      //_client.write("Hellow World");
    } );
  }

  @override
  void onClose() {
    debugPrint("ScreenController onClose");
    super.onClose();
    videoPlayerController?.dispose();
  }
}