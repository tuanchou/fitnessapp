import "package:flutter/material.dart";
import "package:video_player/video_player.dart";

class Videoplayerwidget extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  const Videoplayerwidget({
    super.key,
    required this.videoUrl,
    this.autoPlay = false,
  });

  @override
  _VideoplayerwidgetState createState() => _VideoplayerwidgetState();
}

class _VideoplayerwidgetState extends State<Videoplayerwidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl), // Replace this with your video URL
    );
    _controller.setLooping(true);
    _controller.initialize().then((_) {
      if (widget.autoPlay) {
        _controller.play();
        // Phát video nếu autoPlay là true
      } else {
        _controller.pause(); // Tạm dừng video nếu autoPlay là false
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
