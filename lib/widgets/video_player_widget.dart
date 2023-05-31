import 'package:billboard/widgets/base_widgets.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends BaseWidget {

  const VideoPlayerWidget( {
    super.key,
    this.videoController,
  });

  final VideoPlayerController? videoController;

  @override
  Widget build(BuildContext context) {
    if (videoController != null && videoController?.value.isInitialized == true) {
      return AspectRatio (
          aspectRatio: videoController?.value.aspectRatio ?? 0.00,
          child: VideoPlayer(videoController!),
        );
    } else {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
  }
}