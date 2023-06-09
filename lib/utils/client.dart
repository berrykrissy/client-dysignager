import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class Client {

  late Socket socket;

  Future<void> initialize() async {
    //Create socket and connect to server
    final ip = "0.0.0.0";
    const port = 3000;
    socket = await Socket.connect(ip, port);
    debugPrint("Client: Connected to : ${socket.remoteAddress.address}:${socket.remotePort}");
    socket.listen (
      (Uint8List data) {
        final serverResponse = String.fromCharCodes(data);
        debugPrint("Client: $serverResponse");
      }, onDone: () {
        debugPrint("Client: Server Left");
      }, onError: (error) {
        debugPrint("Client: onError $error");
        socket.destroy();
      },
    );
    /*
    String? username;
    do {
      debugPrint("Client: Please enter username");
      username = stdin.readLineSync();
    } while (username == null || username.isEmpty);
      socket.write(username);
    */
  }

  Future<void> write(String data) async {
    if(data.isNotEmpty) {
      socket.write(data);
    }
  }
}