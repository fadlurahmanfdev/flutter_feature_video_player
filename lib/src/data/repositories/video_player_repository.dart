import 'package:flutter_feature_video_player/src/data/model/hls_resolution_video_model.dart';
import 'package:flutter_feature_video_player/src/data/model/hls_subtitle_video_model.dart';

abstract class VideoPlayerRepository {
  Future<String?> getHlsContent(String videoUrl);

  // reference [https://github.com/apieceofcode1801/flutter_video_player]
  // reference [https://github.com/flutter/flutter/issues/58854]
  /// get quality of video from url video
  Future<List<HlsResolutionVideoModel>> getResolutionsOfVideo(String videoUrl);

  // reference [https://github.com/apieceofcode1801/flutter_video_player]
  // reference [https://github.com/flutter/flutter/issues/58854]
  /// get quality of video from url video
  Future<List<HlsResolutionVideoModel>> getResolutionsOfVideoWithHlsContent(
    String videoUrl, {
    required String hlsContent,
  });

  // reference [https://github.com/flutter/flutter/issues/144828]
  // reference [https://github.com/flutter/flutter/issues/144828#issuecomment-1987885984]
  // reference [https://github.com/flutter/flutter/issues/144828#issuecomment-1986396933]
  /// get subtitles of video from url video
  Future<List<HlsSubtitleVideoModel>> getSubtitlesOfVideo(String videoUrl);

  // reference [https://github.com/flutter/flutter/issues/144828]
  // reference [https://github.com/flutter/flutter/issues/144828#issuecomment-1987885984]
  // reference [https://github.com/flutter/flutter/issues/144828#issuecomment-1986396933]
  /// get subtitles of video from url video
  Future<List<HlsSubtitleVideoModel>> getSubtitlesOfVideoWithHlsContent(
    String videoUrl, {
    required String hlsContent,
  });
}
