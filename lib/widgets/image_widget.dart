import 'package:billboard/widgets/base_widgets.dart';
import 'package:flutter/material.dart';

class ImageWidget extends BaseWidget {
  
  ImageWidget( {
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
      height: 200,
      width: 200,
      alignment: Alignment.center,
      errorBuilder: ( (context, error, stackTrace) {
        return const Icon(
          Icons.broken_image,
          color: Colors.red,
          size: 30.0,
        );
      } ),
    );
  }
}