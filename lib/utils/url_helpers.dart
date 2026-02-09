// YouTube URL validation and manipulation utilities

class UrlHelpers {
  // Validates if a URL is a valid YouTube URL
  static bool isYouTubeUrl(String url) {
    if (url.isEmpty) return false;
    
    final youtubeRegex = RegExp(
      r'^(https?:\/\/)?(www\.|m\.)?(youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    
    return youtubeRegex.hasMatch(url);
  }

  // Extracts YouTube video ID from a URL
  static String? extractYouTubeId(String url) {
    if (!isYouTubeUrl(url)) return null;

    // Handle youtu.be format
    final shortMatch = RegExp(r'youtu\.be\/([a-zA-Z0-9_-]{11})').firstMatch(url);
    if (shortMatch != null) return shortMatch.group(1);

    // Handle youtube.com format
    final longMatch = RegExp(r'[?&]v=([a-zA-Z0-9_-]{11})').firstMatch(url);
    if (longMatch != null) return longMatch.group(1);

    return null;
  }

  // Normalizes a YouTube URL to standard format
  static String? normalizeYouTubeUrl(String url) {
    final videoId = extractYouTubeId(url);
    if (videoId == null) return null;

    return 'https://www.youtube.com/watch?v=$videoId';
  }
}
