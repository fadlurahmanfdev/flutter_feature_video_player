import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_feature_video_player/feature_video_player.dart';
import 'package:video_player/video_player.dart';

class HlsVideoPlayerScreen extends StatefulWidget {
  const HlsVideoPlayerScreen({super.key});

  @override
  State<HlsVideoPlayerScreen> createState() => _HlsVideoPlayerScreenState();
}

class _HlsVideoPlayerScreenState extends State<HlsVideoPlayerScreen> {
  late VideoPlayerService videoPlayerService;
  bool isAlreadyInitialized = false;
  bool isSelectingQualityOfVideo = false;
  bool isSelectingSubtitleOfVideo = false;
  List<HlsResolutionVideoModel> resolutionsVideo = [];
  List<HlsSubtitleVideoModel> subtitlesVideo = [];
  ValueNotifier<String?> subtitleTextNotifier = ValueNotifier(null);
  ValueNotifier<HlsResolutionVideoModel?> selectedResolutionNotifier =
      ValueNotifier(null);
  ValueNotifier<bool> isResolutionSelectedByUserNotifier = ValueNotifier(false);
  ValueNotifier<HlsSubtitleVideoModel?> selectedSubtitleNotifier =
      ValueNotifier(null);

  void onVideoPlayerControllerInitialize() {
    isAlreadyInitialized = true;
    setState(() {});
  }

  void onGetResolutionsOfVideo(List<HlsResolutionVideoModel> resolutions) {
    setState(() {
      resolutionsVideo.clear();
      resolutionsVideo.addAll(resolutions);
    });
  }

  void onResolutionChanged(
    HlsResolutionVideoModel resolution, {
    required bool isSelectedByUser,
  }) {
    selectedResolutionNotifier.value = resolution;
    isResolutionSelectedByUserNotifier.value = isSelectedByUser;
  }

  void onGetSubtitlesOfVideo(List<HlsSubtitleVideoModel> subtitlesVideo) {
    setState(() {
      subtitlesVideo.clear();
      subtitlesVideo.addAll(subtitlesVideo);
    });
  }

  void onSubtitleChanged(HlsSubtitleVideoModel subtitle) {
    selectedSubtitleNotifier.value = subtitle;
  }

  void onSubtitleTextChanged(String? subtitleText) {
    subtitleTextNotifier.value = subtitleText;
  }

  @override
  void initState() {
    super.initState();
    videoPlayerService = VideoPlayerService(
      repository: VideoPlayerRepositoryImpl(),
      onVideoPlayerControllerInitialize: onVideoPlayerControllerInitialize,
    );
    videoPlayerService.playHLS(
      "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
      // "https://mtoczko.github.io/hls-test-streams/test-group/playlist.m3u8",
      // "https://sfux-ext.sfux.info/hls/chapter/105/1588724110/1588724110.m3u8",
      onGetResolutionsOfVideo: onGetResolutionsOfVideo,
      onResolutionChanged: onResolutionChanged,
      onGetSubtitlesOfVideo: onGetSubtitlesOfVideo,
      onSubtitleChanged: onSubtitleChanged,
      onSubtitleTextChanged: onSubtitleTextChanged,
    );
  }

  @override
  void dispose() {
    videoPlayerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: isAlreadyInitialized
            ? Column(
                children: [
                  AspectRatio(
                    aspectRatio:
                        videoPlayerService.controller.value.aspectRatio,
                    child: VideoPlayer(videoPlayerService.controller),
                  ),
                  const SizedBox(height: 10),
                  ValueListenableBuilder(
                    valueListenable: subtitleTextNotifier,
                    builder: (_, value, __) {
                      return Visibility(
                        visible: value != null,
                        child: ClosedCaption(
                          text: value,
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: videoControlWidget(),
                    ),
                  ),
                ],
              )
            : Container(),
      ),
    );
  }

  Widget videoControlWidget() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () async {
                setState(() {
                  isSelectingQualityOfVideo = !isSelectingQualityOfVideo;
                });
              },
              child: Row(
                children: [
                  const Icon(Icons.settings),
                  const SizedBox(width: 5),
                  ValueListenableBuilder(
                    valueListenable: isResolutionSelectedByUserNotifier,
                    builder: (_, isSelectedByUser, __) {
                      return ValueListenableBuilder(
                        valueListenable: selectedResolutionNotifier,
                        builder: (_, quality, __) {
                          return Text(
                            "${quality?.name}${isSelectedByUser ? "" : " (Auto)"}",
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                setState(() {
                  isSelectingSubtitleOfVideo = !isSelectingSubtitleOfVideo;
                });
              },
              child: ValueListenableBuilder(
                  valueListenable: selectedSubtitleNotifier,
                  builder: (_, selectedSubtitle, __) {
                    return Row(
                      children: [
                        Icon(
                          selectedSubtitle != null
                              ? Icons.closed_caption
                              : Icons.closed_caption_disabled,
                        ),
                        const SizedBox(width: 5),
                        Text(selectedSubtitle?.language ?? "-"),
                      ],
                    );
                  }),
            ),
          ],
        ),
        Visibility(
          visible: isSelectingQualityOfVideo,
          child: ValueListenableBuilder(
            valueListenable: selectedResolutionNotifier,
            builder: (_, resolution, __) {
              return selectResolutionsOfVideoWidget(
                resolutionsVideo,
                selectedQuality: resolution,
              );
            },
          ),
        ),
        Visibility(
          visible: isSelectingSubtitleOfVideo,
          child: ValueListenableBuilder(
            valueListenable: selectedSubtitleNotifier,
            builder: (_, subtitle, __) {
              return selectSubtitleOfVideoWidget(
                subtitlesVideo,
                selectedSubtitle: subtitle,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget selectResolutionsOfVideoWidget(
    List<HlsResolutionVideoModel> qualitiesOfVideo, {
    HlsResolutionVideoModel? selectedQuality,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 20),
        Text("Resolution Of Video ${selectedQuality?.name}"),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: qualitiesOfVideo
              .map((e) => GestureDetector(
                    onTap: () async {
                      setState(() {
                        isSelectingQualityOfVideo = false;
                      });
                      videoPlayerService.setQuality(e);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(e.name),
                        Visibility(
                          visible: selectedQuality?.name == e.name,
                          child: const Icon(Icons.check),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        )
      ],
    );
  }

  Widget selectSubtitleOfVideoWidget(
    List<HlsSubtitleVideoModel> subtitlesOfVideo, {
    HlsSubtitleVideoModel? selectedSubtitle,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 20),
        const Text("Subtitles Of Video"),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: subtitlesOfVideo
              .map((e) => GestureDetector(
                    onTap: () async {
                      setState(() {
                        isSelectingSubtitleOfVideo = false;
                      });
                      videoPlayerService.setSubtitle(e);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(e.language),
                        Visibility(
                          visible: selectedSubtitle?.language == e.language,
                          child: const Icon(Icons.check),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        )
      ],
    );
  }
}
