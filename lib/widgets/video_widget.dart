import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final File file;
  final String networkUrl;
  final bool isFromNetwork;
  final double width;
  final double height;

  const VideoWidget(
      this.file, this.networkUrl, this.isFromNetwork, this.width, this.height);

  @override
  VideoWidgetState createState() => VideoWidgetState();
}

class VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  late Widget videoStatusAnimation;

  @override
  void initState() {
    super.initState();

    videoStatusAnimation = Container();

    if (widget.file.path != '') {
      _controller = VideoPlayerController.file(widget.file)
        ..addListener(() {
          final bool isPlaying = _controller.value.isPlaying;
          if (isPlaying != _isPlaying) {
            setState(() {
              _isPlaying = isPlaying;
            });
          }
        })
        ..initialize().then((_) {
          Timer(Duration(milliseconds: 0), () {
            if (!mounted) return;

            setState(() {});
            _controller.pause();
          });
        });
    } else {
      _controller = VideoPlayerController.network(widget.networkUrl)
        ..addListener(() {
          final bool isPlaying = _controller.value.isPlaying;
          if (isPlaying != _isPlaying) {
            setState(() {
              _isPlaying = isPlaying;
            });
          }
        })
        ..initialize().then((_) {
          Timer(Duration(milliseconds: 0), () {
            if (!mounted) return;

            setState(() {});
            _controller.play();
          });
        });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: widget.height,
        width: widget.width,
        child: Stack(
          children: [
            SizedBox(
              height: widget.height,
              width: widget.width,
              child: FittedBox(
                clipBehavior: Clip.hardEdge,
                child: Container(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: _controller.value.isInitialized
                      ? videoPlayer()
                      : Container(),
                ),
                fit: BoxFit.cover,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                padding: EdgeInsets.all(16.0),
              ),
            ),
            Center(child: videoStatusAnimation),
          ],
        ),
      );

  // @override
  // Widget build(BuildContext context) => AspectRatio(
  //   aspectRatio: _controller.value.aspectRatio,//16 / 16,
  //   child: _controller.value.isInitialized ? videoPlayer() : Container(),
  // );

  Widget videoPlayer() => Stack(
        children: <Widget>[
          video(),
        ],
      );

  Widget video() => GestureDetector(
        child: VideoPlayer(_controller),
        onTap: () {
          tappedVideo();
        },
      );

  void tappedVideo() {
    if (!_controller.value.isInitialized) {
      return;
    }
    if (_controller.value.isPlaying) {
      videoStatusAnimation = GestureDetector(
          onTap: () {
            tappedVideo();
          },
          child: const FadeAnimation(child: Icon(Icons.pause, size: 100.0)));
      _controller.pause();
    } else {
      videoStatusAnimation = GestureDetector(
          onTap: () {
            tappedVideo();
          },
          child: const FadeAnimation(
              child: Icon(Icons.play_arrow, size: 100.0)));
      _controller.play();
    }
  }
}

class FadeAnimation extends StatefulWidget {
  const FadeAnimation(
      {required this.child,
      this.duration = const Duration(milliseconds: 1000)});

  final Widget child;
  final Duration duration;

  @override
  _FadeAnimationState createState() => _FadeAnimationState();
}

class _FadeAnimationState extends State<FadeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: widget.duration, vsync: this);
    animationController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    animationController.forward(from: 0.0);
  }

  @override
  void deactivate() {
    animationController.stop();
    super.deactivate();
  }

  @override
  void didUpdateWidget(FadeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => animationController.isAnimating
      ? Opacity(
          opacity: 1.0 - animationController.value,
          child: widget.child,
        )
      : Container();
}
