import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';

class ReelVideoCacheManager {
  ReelVideoCacheManager._();
  static final ReelVideoCacheManager instance = ReelVideoCacheManager._();

  /// Dedicated CacheManager for reel videos.
  /// Max 25 videos with 3 days retention to manage storage cleanly.
  final CacheManager _cacheManager = CacheManager(
    Config(
      'reel_videos_cache',
      stalePeriod: const Duration(days: 3),
      maxNrOfCacheObjects: 25,
      repo: JsonCacheInfoRepository(databaseName: 'reel_videos_cache'),
      fileService: HttpFileService(),
    ),
  );

  /// Check if video file is already cached on disk
  Future<File?> getCachedFile(String url) async {
    if (url.isEmpty) return null;
    try {
      final fileInfo = await _cacheManager.getFileFromCache(url);
      if (fileInfo != null && await fileInfo.file.exists()) {
        return fileInfo.file;
      }
    } catch (e) {
      debugPrint("Error checking video cache: $e");
    }
    return null;
  }

  /// Pre-cache video to disk in the background (fire and forget)
  Future<void> preCacheVideoToDisk(String url) async {
    if (url.isEmpty) return;
    try {
      final fileInfo = await _cacheManager.getFileFromCache(url);
      if (fileInfo == null) {
        await _cacheManager.downloadFile(url);
      }
    } catch (e) {
      debugPrint("Pre-cache disk download error: $e");
    }
  }

  /// Create a VideoPlayerController using disk cache if available, or streaming networkUrl.
  /// If using networkUrl, simultaneously triggers background disk caching for future playback.
  Future<VideoPlayerController> createController(String url) async {
    try {
      final cachedFile = await getCachedFile(url);
      if (cachedFile != null) {
        return VideoPlayerController.file(cachedFile);
      }
    } catch (e) {
      debugPrint("Failed to create controller from cached file: $e");
    }

    // Trigger background caching to disk for subsequent loops and re-visits
    preCacheVideoToDisk(url);
    return VideoPlayerController.networkUrl(Uri.parse(url));
  }

  /// Clear video disk cache if needed
  Future<void> clearCache() async {
    try {
      await _cacheManager.emptyCache();
    } catch (e) {
      debugPrint("Failed to clear video cache: $e");
    }
  }
}
