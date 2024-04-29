import 'dart:developer';
import 'package:flutter_feature_video_player/src/data/model/hls_resolution_video_model.dart';
import 'package:flutter_feature_video_player/src/data/model/hls_subtitle_video_model.dart';
import 'package:flutter_feature_video_player/src/data/repositories/video_player_repository.dart';
import 'package:http/http.dart' as http;

import 'package:video_player/video_player.dart';

class VideoPlayerService {
  VideoPlayerRepository repository;
  Function() onVideoPlayerControllerInitialize;

  // hls
  /// on get url video of qualities
  Function(List<HlsResolutionVideoModel> qualitiesVideo)? onGetQualitiesOfVideo;
  Function(
    HlsResolutionVideoModel quality, {
    required bool isSelectedByUser,
  })? onQualityChanged;
  Function(List<HlsSubtitleVideoModel> subtitlesVideo)? onGetSubtitlesOfVideo;
  Function(HlsSubtitleVideoModel subtitle)? onSubtitleChanged;
  Function(String? subtitleText)? onSubtitleTextChanged;

  late VideoPlayerController _controller;

  VideoPlayerController get controller => _controller;

  VideoPlayerService({
    required this.repository,
    required this.onVideoPlayerControllerInitialize,
  });

  void Function() videoListener = () {};

  Future<void> playHLS(
    String hlsVideoUrl, {
    Function(List<HlsResolutionVideoModel> qualitiesVideo)?
        onGetQualitiesOfVideo,
    Function(
      HlsResolutionVideoModel quality, {
      required bool isSelectedByUser,
    })? onQualityChanged,
    Function(List<HlsSubtitleVideoModel> subtitlesVideo)? onGetSubtitlesOfVideo,
    Function(HlsSubtitleVideoModel subtitle)? onSubtitleChanged,
    Function(String? subtitleText)? onSubtitleTextChanged,
  }) async {
    if (onGetQualitiesOfVideo != null) {
      this.onGetQualitiesOfVideo = onGetQualitiesOfVideo;
    }

    if (onQualityChanged != null) {
      this.onQualityChanged = onQualityChanged;
    }

    if (onGetSubtitlesOfVideo != null) {
      this.onGetSubtitlesOfVideo = onGetSubtitlesOfVideo;
    }

    if (onSubtitleChanged != null) {
      this.onSubtitleChanged = onSubtitleChanged;
    }

    if (onSubtitleTextChanged != null) {
      this.onSubtitleTextChanged = onSubtitleTextChanged;
    }

    try {
      final hlsContent =
          await repository.getHlsContent(hlsVideoUrl);
      if (hlsContent == null) {
        log("failed playHLS: hlsContent is missing");
        return;
      }

      final resolutions =
          await repository.getResolutionsOfVideoWithHlsContent(
        hlsVideoUrl,
        hlsContent: hlsContent,
      );

      this.onGetQualitiesOfVideo != null
          ? this.onGetQualitiesOfVideo!(resolutions)
          : null;

      final subtitles =
          await repository.getSubtitlesOfVideoWithHlsContent(
        hlsVideoUrl,
        hlsContent: hlsContent,
      );

      this.onGetSubtitlesOfVideo != null
          ? this.onGetSubtitlesOfVideo!(subtitles)
          : null;

      if (resolutions.isNotEmpty) {
        final quality = resolutions.last;
        this.onQualityChanged != null
            ? this.onQualityChanged!(
                quality,
                isSelectedByUser: false,
              )
            : null;

        _controller = VideoPlayerController.networkUrl(
          Uri.parse(quality.url),
          formatHint: VideoFormat.hls,
        )..initialize().then((value) {
            onVideoPlayerControllerInitialize();
            setControllerListener();
            controller.play();
            // todo: remove (dev tools only)
            controller.seekTo(Duration(seconds: 105));
          });
      }
    } on Exception catch (e) {
      log("failed playHLS: $e");
    }
  }

  void setControllerListener() {
    controller.addListener(() {
      // todo: remove (dev tools only)
      log("POSITION: ${controller.value.position.inSeconds}");
      log("DURATION: ${controller.value.duration.inSeconds}");
      log("TEXT: ${controller.value.caption.text}");

      onSubtitleTextChanged != null
          ? onSubtitleTextChanged!(
              controller.value.caption.text.isNotEmpty
                  ? controller.value.caption.text
                  : null,
            )
          : null;
    });
  }

  Future<void> setQuality(HlsResolutionVideoModel model) async {
    onQualityChanged != null
        ? onQualityChanged!(model, isSelectedByUser: true)
        : null;
    Duration? lastPosition = await _controller.position;
    _controller.pause();
    _controller.removeListener(() {});

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(model.url),
      formatHint: VideoFormat.hls,
    )..initialize().then((value) {
        setControllerListener();
        controller.play();

        if (lastPosition != null) {
          controller.seekTo(lastPosition);
        }
      });
  }

  Future<void> setSubtitle(HlsSubtitleVideoModel subtitle) async {
    try {
      final vttString = await http.get(Uri.parse(subtitle.url));
      log("VTT STRING: ${vttString.body}");
      _controller
          .setClosedCaptionFile(Future.value(WebVTTCaptionFile(vttString.body)))
          .then(
        (_) {
          onSubtitleChanged != null ? onSubtitleChanged!(subtitle) : null;
        },
      );
    } on Exception catch (e) {
      log("failed setSubtitle: $e");
    }
  }

  void dispose() {
    _controller.pause();
    _controller.removeListener(() {});
    _controller.dispose();
  }
}
