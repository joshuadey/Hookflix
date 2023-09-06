import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoViewer extends StatefulWidget {
  const VideoViewer({super.key, required this.movieUrl});

  final String movieUrl;

  @override
  State<VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    _controller = VideoPlayerController.network(widget.movieUrl);

    _initializeVideoPlayerFuture = _controller.initialize().then((value) {});
    _controller.play();
    _controller.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: Container(
          color: Colors.black54,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // top bar
              Padding(
                padding: EdgeInsets.all(8),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        'Preview video',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 3,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                thickness: 1,
                color: Colors.white54,
              ),

              // main box
              Padding(
                padding: EdgeInsets.all(8),
                child: Container(
                  // height: 350,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_controller.value.isInitialized) {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                            }
                          }
                        },
                        child: FutureBuilder(
                          future: _initializeVideoPlayerFuture,
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                _controller.value.isInitialized) {
                              return Container(
                                width: double.infinity,
                                height: 320,
                                child: AspectRatio(
                                  aspectRatio: _controller.value.aspectRatio,
                                  child: VideoPlayer(_controller),
                                ),
                              );
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          },
                        ),
                      ),

                      SizedBox(height: 20),

                      // progress indicator
                      Row(
                        children: [
                          Text(
                            getPosition(),
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: VideoProgressIndicator(
                              _controller,
                              allowScrubbing: (_controller.value.isInitialized),
                              colors: VideoProgressColors(),
                              padding: EdgeInsets.all(8.0),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            getDuration(),
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  String getPosition() {
    final duration = Duration(
        milliseconds: _controller.value.position.inMilliseconds.round());

    if (duration.inHours > 0) {
      return [duration.inHours, duration.inMinutes, duration.inSeconds]
          .map((e) => e.remainder(60).toString().padLeft(2, '0'))
          .join(':');
    } else {
      return [duration.inMinutes, duration.inSeconds]
          .map((e) => e.remainder(60).toString().padLeft(2, '0'))
          .join(':');
    }
  }

  String getDuration() {
    final duration = Duration(
        milliseconds: _controller.value.duration.inMilliseconds.round());

    if (duration.inHours > 0) {
      return [duration.inHours, duration.inMinutes, duration.inSeconds]
          .map((e) => e.remainder(60).toString().padLeft(2, '0'))
          .join(':');
    } else {
      return [duration.inMinutes, duration.inSeconds]
          .map((e) => e.remainder(60).toString().padLeft(2, '0'))
          .join(':');
    }
  }

}
