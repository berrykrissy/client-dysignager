import 'package:billboard/widgets/base_widgets.dart';
import 'package:flutter/material.dart';

class ImageWidget extends BaseWidget {
  
  ImageWidget ( {
    super.key,
    this.url,
  } );

  String? url;

  @override
  Widget build(BuildContext context) {
    //return Image.asset("assets/image.jpg");
    return Image.network (
      url ?? "",
      fit: BoxFit.cover,
      alignment: Alignment.center,
      errorBuilder: ( (context, error, stackTrace) {
        debugPrint("ImageWidget errorBuilder ${error.toString()} ${stackTrace.toString()}");
        return const Icon (
          Icons.broken_image,
          color: Colors.red,
          size: 30.0,
        );
      } ),
    );
  }
}