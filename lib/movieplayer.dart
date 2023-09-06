import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_icons/flutter_icons.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_app/widgets/removeThumb.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';
import 'package:subtitle/subtitle.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class MoviePlayer extends StatefulWidget {
  const MoviePlayer({
    Key? key,
    required this.movieTitle,
    required this.movieUrl,
    required this.movie_id,
    required this.subtitle,
    required this.preview,
  }) : super(key: key);

  final String movieUrl;
  final String movieTitle;
  final String movie_id;
  final String subtitle;
  final bool preview;

  @override
  State<MoviePlayer> createState() => _MoviePlayerState();
}

class _MoviePlayerState extends State<MoviePlayer> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  bool _isFullScreen = false;
  bool slider_idle = true;

  final allSpeeds = <double>[0.25, 0.5, 1, 1.5, 2, 3, 5, 10];

  Orientation? target;
  bool? isPotrait;
  bool? isLandscape;

  bool showControls = true;

  bool isLocked = false;
  bool showLock = false;

  double _volume = 0.5;
  bool showVolumeSlider = false;

  double _brightness = 0.7;
  bool showBrightness_slider = false;

  String subtitleText = '';

  // bool to check controller to return state after changing speed
  bool wasPlaying = true;
  bool subtitleEnabled = true;

  Timer? _timer;

  void _timerStart() {
    if (_timer != null) return;

    if (_controller.value.isInitialized)
      _timer = Timer.periodic(Duration(seconds: 5), _timerFun);
  }

  void _timerStop() {
    if (_timer != null) _timer!.cancel();
    _timer = null;
  }

  void _timerReset() {
    if (_timer != null) _timerStop();
    _timerStart();
  }

  void _timerFun(Timer timer) {
    _timerStop();

    if (!_controller.value.isPlaying ||
        showVolumeSlider ||
        _controller.value.isBuffering) return;
    setState(() {
      showControls = false;
      showLock = false;
    });
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    load();
    if (!widget.preview) loadSubtitle();

    Wakelock.enable();

    super.initState();

    // nativeOrientationCom();
  }

  @override
  void dispose() {
    // Dispose of the video player controller when the widget is closed
    _timerStop();
    _controller.removeListener(() {});
    _controller.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    Wakelock.disable();

    super.dispose();
  }

  // load and initialize all
  load() async {
    var box = Hive.box('lastDuration');

    // if preview turn off subtitle
    subtitleEnabled = !widget.preview;

    // Initialize the video player controller
    _controller = VideoPlayerController.network(widget.movieUrl);

    // Ensure the video is initialized
    // _initializeVideoPlayerFuture = _controller
    //     .initialize()
    //     .onError((error, stackTrace) => Navigator.pop(context));

    _initializeVideoPlayerFuture = _controller.initialize().then((value) async {
      // get saved movie data
      if (!widget.preview) {
        Map? movie_dt = box.get(widget.movie_id);

        // update movie with saved data
        if (movie_dt != null) {
          Duration last = parseTime(movie_dt['lastDuration']) ?? Duration();

          // update last position
          if (last > Duration(minutes: 2)) {
            _controller.seekTo(last);
          }

          // update volume
          _controller.setVolume(movie_dt['volume']);
          _volume = movie_dt['volume'];
        } else {
          _controller.setVolume(0.5);
        }
      }

      // get system brightness
      if (!kIsWeb) ScreenBrightness().setScreenBrightness(_brightness);

      // Start playing the video automatically
      _controller.play();

      // movvie listener
      _controller.addListener(() {
        if (!_controller.value.isPlaying &&
            (_controller.value.duration != _controller.value.position)) return;

        setState(() {});

        // save movie data
        Map movie_data = {
          'lastDuration': _controller.value.position.toString(),
          'volume': _controller.value.volume,
        };

        if (_controller.value.position > Duration(minutes: 2) &&
            !widget.preview) box.put(widget.movie_id, movie_data);

        // close player when done
        if (!_controller.value.isPlaying &&
            _controller.value.isInitialized &&
            (_controller.value.duration == _controller.value.position)) {
          if (!widget.preview) box.delete(widget.movie_id);
          Navigator.pop(context, 'done');
        }
      });
    });
  }

  loadSubtitle() async {
    // initialize subtitle
    var url = Uri.parse(widget.subtitle);
    var controller = SubtitleController(
      provider: SubtitleProvider.fromNetwork(url),
    );

    await controller.initial();

    Subtitle s =
        Subtitle(start: Duration(), end: Duration(), data: '', index: 0);

    _controller.addListener(() {
      // search subtile
      var val = _controller.value.position;
      s = controller.durationSearch(val) ??
          Subtitle(start: Duration(), end: Duration(), data: '', index: 0);

      // update subtitle
      if (s.data.isNotEmpty) {
        subtitleText = s.data;
      } else {
        subtitleText = '';
      }
    });
  }

  // auto orientation
  nativeOrientationCom() {
    NativeDeviceOrientationCommunicator()
        .onOrientationChanged(useSensor: true)
        .listen((event) {
      final isP = event == NativeDeviceOrientation.portraitUp;
      final isL = event == NativeDeviceOrientation.landscapeLeft ||
          event == NativeDeviceOrientation.landscapeRight;

      final isTargetP = target == Orientation.portrait;
      final isTargetL = target == Orientation.landscape;

      if (isP == isTargetP || isL == isTargetL) {
        target = null;
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(24, 24, 24, 1),
      body: OrientationBuilder(builder: (context, orientation) {
        isPotrait = orientation == Orientation.portrait;
        isLandscape = orientation == Orientation.landscape;

        target = isPotrait! ? Orientation.landscape : Orientation.portrait;

        return Listener(
          onPointerDown: (_) => _timerReset(),
          onPointerMove: (_) => _timerReset(),
          onPointerUp: (_) => _timerReset(),
          child: Stack(
            fit: isPotrait! ? StackFit.loose : StackFit.expand,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (!_controller.value.isInitialized) return;

                  if (isLocked) {
                    if (showControls) showControls = false;

                    setState(() {
                      showLock = true;
                    });
                  } else {
                    setState(() {
                      showControls = true;
                    });
                  }
                },
                onDoubleTap: () {
                  if (!_controller.value.isInitialized) return;

                  if (isLocked) {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  }
                },
                child: FutureBuilder(
                  future: _initializeVideoPlayerFuture,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        _controller.value.isInitialized) {
                      _timerStart();
                      return LayoutBuilder(builder: (context, constraints) {
                        return Container(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          ),
                        );
                      });
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),

              // subtitle
              !subtitleEnabled
                  ? Container()
                  : Positioned(
                      bottom: isPotrait! ? 150 : 90,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Text(
                            subtitleText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                backgroundColor: Colors.black26),
                          ),
                        ],
                      ),
                    ),

              Positioned.fill(
                child: (!showControls) ? Container() : _buildControls(),
              ),

              _buildSliders(),

              isLocked || (!_controller.value.isInitialized)
                  ? Container()
                  : _gestureButton(),

              isLocked || (!_controller.value.isInitialized) || !showControls
                  ? Container()
                  : _controls(),

              // top lock button
              isLocked && showLock
                  ? Positioned(
                      top: 25,
                      right: 18,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            Future.delayed(Duration(milliseconds: 200), () {
                              setState(() {
                                isLocked = false;
                                showControls = true;
                              });
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromARGB(45, 255, 255, 255),
                                border: Border.all(
                                  color: Colors.black54,
                                )),
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.lock,
                              size: 35,
                              color: Color.fromARGB(89, 229, 56, 53),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        );
      }),
    );
  }

  // widgets
  Widget _buildControls() {
    return Container(
      color: Color.fromARGB(91, 35, 27, 27),
      child: Stack(
        children: <Widget>[
          // top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              // color: Colors.black87,
              padding: EdgeInsets.all(10),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      !widget.preview
                          ? widget.movieTitle
                          : '${widget.movieTitle} (Trailer)',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        size: 30,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              // color: Colors.black87,
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
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
                          allowScrubbing:
                              (_controller.value.isInitialized) && !isLocked,
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

                  SizedBox(height: 4),

                  // options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 20),

                      (widget.preview)
                          ? Text(
                              'Preview',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: (!_controller.value.isInitialized)
                                    ? Colors.white30
                                    : Colors.white,
                              ),
                            )
                          : Container(),

                      Expanded(child: Container()),
                      // screen lock
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: GestureDetector(
                          child: Row(
                            children: [
                              Icon(
                                !isLocked ? Icons.lock_open : Icons.lock,
                                color: (!_controller.value.isInitialized)
                                    ? Colors.white30
                                    : Colors.white,
                                size: 25,
                              ),
                              SizedBox(width: 6),
                              Text(
                                !isLocked ? 'Lock' : 'Unlock',
                                style: TextStyle(
                                  color: (!_controller.value.isInitialized)
                                      ? Colors.white30
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          onTap: _toggleLock,
                        ),
                      ),

                      isLocked ? Container() : SizedBox(width: 20),

                      // Expanded(child: Container()),
                      isLocked
                          ? Container()
                          // subtitles
                          : _buildSubtitle(),

                      isLocked ? Container() : SizedBox(width: 30),

                      isLocked ? Container() : _buildSpeed(),

                      Expanded(child: Container()),

                      isLocked
                          ? Container()
                          // volume button
                          : Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: GestureDetector(
                                child: Icon(
                                  volume_off ||
                                          (!_controller.value.isInitialized)
                                      ? Icons.volume_off
                                      : _controller.value.volume < 0.5
                                          ? Icons.volume_down
                                          : Icons.volume_up,
                                  color: (!_controller.value.isInitialized)
                                      ? Colors.white30
                                      : Colors.white,
                                  size: 30,
                                ),
                                onTap: _toggleVolume,
                              ),
                            ),

                      isLocked ? Container() : SizedBox(width: 30),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliders() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // brightness
                (!showBrightness_slider)
                    ? Container()
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.brightness_high,
                            color: Colors.white70,
                            size: 20,
                          ),
                          SizedBox(height: 56),
                          Transform.rotate(
                            angle: -(90 * pi / 180),
                            child: SliderTheme(
                              data: getNoThumbSliderTheme(context),
                              child: Slider(
                                activeColor: Colors.white,
                                inactiveColor: Colors.white38,
                                value: _brightness,
                                onChanged: (double value) {},
                              ),
                            ),
                          ),
                          SizedBox(height: 56),
                          Icon(
                            Icons.brightness_low,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ],
                      ),

                // volume
                (!showVolumeSlider)
                    ? Container()
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.volume_up,
                            color: Colors.white70,
                            size: 20,
                          ),
                          SizedBox(height: 56),
                          Transform.rotate(
                            angle: -(90 * pi / 180),
                            child: SliderTheme(
                              data: getNoThumbSliderTheme(context),
                              child: Slider(
                                activeColor: Colors.white,
                                inactiveColor: Colors.white38,
                                value: _volume,
                                onChanged: (double value) {},
                              ),
                            ),
                          ),
                          SizedBox(height: 56),
                          Icon(
                            Icons.volume_down,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // subtitle
  Widget _buildSubtitle() {
    return Container(
      child: PopupMenuButton<int>(
        offset: Offset(50, -80),
        color: Colors.black87,
        enabled: _controller.value.isInitialized && !widget.preview,
        onOpened: () {
          setState(() {
            wasPlaying = _controller.value.isPlaying;
          });
          _controller.pause();
        },
        onCanceled: () {
          if (wasPlaying) {
            _controller.play();
          }
        },
        initialValue: (subtitleEnabled) ? 1 : 0,
        tooltip: 'Subtitle track',
        onSelected: (value) {
          setState(() {
            if (value == 1) {
              subtitleEnabled = true;
            } else {
              subtitleEnabled = false;
            }
          });

          if (wasPlaying) {
            _controller.play();
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            enabled: false,
            child: Container(
              child: Center(
                child: Text(
                  'Subtitles',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
          PopupMenuDivider(),
          PopupMenuItem(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            value: 1,
            child: Row(
              children: [
                Icon(
                  subtitleEnabled ? Icons.check : null,
                  color: Colors.white38,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Track 1',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            value: 0,
            child: Row(
              children: [
                Icon(
                  !subtitleEnabled ? Icons.check : null,
                  color: Colors.white38,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Disable',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
        child: Row(
          children: [
            Icon(
              !_controller.value.isInitialized ||
                      !subtitleEnabled ||
                      widget.preview
                  ? Icons.subtitles_off
                  : Icons.subtitles,
              color: (!_controller.value.isInitialized) || widget.preview
                  ? Colors.white30
                  : Colors.white,
              size: 28,
            ),
            SizedBox(width: 6),
            Text(
              'Subtitles',
              style: TextStyle(
                color: (!_controller.value.isInitialized) || widget.preview
                    ? Colors.white30
                    : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // playback speed
  Widget _buildSpeed() {
    return Container(
      child: PopupMenuButton<double>(
        enabled: _controller.value.isInitialized,
        onOpened: () {
          setState(() {
            wasPlaying = _controller.value.isPlaying;
          });
          _controller.pause();
        },
        onCanceled: () {
          if (wasPlaying) {
            _controller.play();
          }
        },
        initialValue: _controller.value.playbackSpeed,
        tooltip: 'Playback speed',
        onSelected: (value) {
          _controller.setPlaybackSpeed(value);
          _controller.play();
        },
        itemBuilder: (context) => allSpeeds
            .map<PopupMenuEntry<double>>((speed) => PopupMenuItem(
                  value: speed,
                  child: Text('${speed}x'),
                ))
            .toList(),
        child: Row(
          children: [
            Icon(
              Icons.speed,
              color: (!_controller.value.isInitialized)
                  ? Colors.white30
                  : Colors.white,
              size: 28,
            ),
            SizedBox(width: 6),
            Text(
              'Speed (${_controller.value.playbackSpeed}x)',
              style: TextStyle(
                  color: (!_controller.value.isInitialized)
                      ? Colors.white30
                      : Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // on screen controls
  Widget _controls() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              FlutterIcons.rewind_10_mco,
              color: Colors.white,
              size: 26,
            ),
            onPressed: _backward,
          ),
          SizedBox(width: 40),
          IconButton(
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 45,
            ),
            onPressed: _togglePlayPause,
          ),
          SizedBox(width: 40),
          IconButton(
            icon: Icon(
              FlutterIcons.fast_forward_10_mco,
              color: Colors.white,
              size: 26,
            ),
            onPressed: _forward,
          ),
        ],
      ),
    );
  }

  bool showLeftTap = false;
  bool showRightTap = false;

  // gestures
  Widget _gestureButton() {
    double size = MediaQuery.of(context).size.width / 2.3;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isPotrait! ? 150 : 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // left
          GestureDetector(
            onDoubleTap: () {
              setState(() {
                showLeftTap = true;
              });
              _backward();
              Future.delayed(Duration(milliseconds: 400), () {
                setState(() {
                  showLeftTap = false;
                });
              });
            },
            onTap: () {
              setState(() {
                showControls = true;
              });
            },
            onVerticalDragUpdate: (DragUpdateDetails details) {
              double sensitivity =
                  0.01; // Adjust this to control the sensitivity of volume change

              if (details.delta.dy < 0) {
                _brightness += sensitivity;
              } else {
                _brightness -= sensitivity;
              }

              // Ensure the volume level stays within 0.0 to 1.0 range
              _brightness = _brightness.clamp(0.0, 1.0);

              ScreenBrightness().setScreenBrightness(_brightness);

              setState(() {
                showBrightness_slider = true;
              });
            },
            onVerticalDragEnd: (DragEndDetails details) {
              Future.delayed(Duration(seconds: 5), () {
                setState(() {
                  showBrightness_slider = false;
                });
              });
            },
            child: Container(
              width: size,
              color: Colors.transparent,
              child: Center(
                child: showLeftTap
                    ? Icon(
                        Icons.fast_rewind,
                        color: Colors.white,
                        size: 40,
                      )
                    : Container(),
              ),
            ),
          ),

          // right
          GestureDetector(
            onDoubleTap: () {
              setState(() {
                showRightTap = true;
              });
              _forward();
              Future.delayed(Duration(milliseconds: 400), () {
                setState(() {
                  showRightTap = false;
                });
              });
            },
            onTap: () {
              setState(() {
                showControls = true;
              });
            },
            onVerticalDragUpdate: (DragUpdateDetails details) {
              double sensitivity =
                  0.01; // Adjust this to control the sensitivity of volume change

              if (details.delta.dy < 0) {
                _volume += sensitivity;
              } else {
                _volume -= sensitivity;
              }

              // Ensure the volume level stays within 0.0 to 1.0 range
              _volume = _volume.clamp(0.0, 1.0);

              _controller.setVolume(_volume);

              setState(() {
                showVolumeSlider = true;
              });
            },
            onVerticalDragEnd: (DragEndDetails details) {
              Future.delayed(Duration(seconds: 5), () {
                setState(() {
                  showVolumeSlider = false;
                });
              });
            },
            child: Container(
              width: size,
              color: Colors.transparent,
              child: Center(
                child: showRightTap
                    ? Icon(
                        Icons.fast_forward,
                        color: Colors.white,
                        size: 40,
                      )
                    : Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // functions

  void _toggleFullScreen() {
    if (!_controller.value.isInitialized) return;

    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  void _toggleLock() {
    if (!_controller.value.isInitialized) return;

    setState(() {
      isLocked = !isLocked;
      showLock = isLocked;
      showControls = !isLocked;
    });
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

  void _forward() {
    if (!_controller.value.isInitialized) return;
    Duration currentPosition = _controller.value.position;
    Duration targetPosition = currentPosition + Duration(seconds: 10);
    _controller.seekTo(targetPosition);
    setState(() {
      showRightTap = true;
    });
    Future.delayed(Duration(milliseconds: 400), () {
      setState(() {
        showRightTap = false;
      });
    });
  }

  void _backward() {
    if (!_controller.value.isInitialized) return;
    Duration currentPosition = _controller.value.position;
    Duration targetPosition = currentPosition - Duration(seconds: 10);
    _controller.seekTo(targetPosition);
    setState(() {
      showLeftTap = true;
    });
    Future.delayed(Duration(milliseconds: 400), () {
      setState(() {
        showLeftTap = false;
      });
    });
  }

  void _togglePlayPause() {
    if (!_controller.value.isInitialized) return;
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        Wakelock.disable();
      } else {
        _controller.play();
        Wakelock.enable();
      }
    });
  }

  double lastVolume = 0;
  bool volume_off = false;

  void _toggleVolume() {
    if (!_controller.value.isInitialized) return;

    if (_controller.value.volume > 0) {
      lastVolume = _controller.value.volume;
      _controller.setVolume(0);
      volume_off = true;
    } else {
      _controller.setVolume(lastVolume);
      volume_off = false;
    }

    setState(() {});
  }

  Duration? parseTime(String input) {
    final parts = input.split(':');

    if (parts.length != 3) return null;

    int days;
    int hours;
    int minutes;
    int seconds;
    int milliseconds;
    int microseconds;

    {
      final p = parts[2].split('.');

      if (p.length != 2) return null;

      // If fractional seconds is passed, but less than 6 digits
      // Pad out to the right so we can calculate the ms/us correctly
      final p2 = int.parse(p[1].padRight(6, '0'));
      microseconds = p2 % 1000;
      milliseconds = p2 ~/ 1000;

      seconds = int.parse(p[0]);
    }

    minutes = int.parse(parts[1]);

    {
      int p = int.parse(parts[0]);
      hours = p % 24;
      days = p ~/ 24;
    }

    // TODO verify that there are no negative parts

    return Duration(
        days: days,
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        milliseconds: milliseconds,
        microseconds: microseconds);
  }

  Future<double> get systemBrightness async {
    try {
      return await ScreenBrightness().system;
    } catch (e) {
      print(e);
      throw 'Failed to get system brightness';
    }
  }
}
