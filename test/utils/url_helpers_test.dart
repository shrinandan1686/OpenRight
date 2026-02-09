import 'package:flutter_test/flutter_test.dart';
import 'package:openright/utils/url_helpers.dart';

void main() {
  group('UrlHelpers.isYouTubeUrl', () {
    test('validates standard youtube.com URLs', () {
      expect(UrlHelpers.isYouTubeUrl('https://www.youtube.com/watch?v=dQw4w9WgXcQ'), true);
      expect(UrlHelpers.isYouTubeUrl('http://www.youtube.com/watch?v=dQw4w9WgXcQ'), true);
      expect(UrlHelpers.isYouTubeUrl('https://youtube.com/watch?v=dQw4w9WgXcQ'), true);
    });

    test('validates youtu.be short URLs', () {
      expect(UrlHelpers.isYouTubeUrl('https://youtu.be/dQw4w9WgXcQ'), true);
      expect(UrlHelpers.isYouTubeUrl('http://youtu.be/dQw4w9WgXcQ'), true);
    });

    test('validates mobile YouTube URLs', () {
      expect(UrlHelpers.isYouTubeUrl('https://m.youtube.com/watch?v=dQw4w9WgXcQ'), true);
    });

    test('rejects non-YouTube URLs', () {
      expect(UrlHelpers.isYouTubeUrl('https://vimeo.com/123456'), false);
      expect(UrlHelpers.isYouTubeUrl('https://google.com'), false);
      expect(UrlHelpers.isYouTubeUrl('https://facebook.com/watch?v=123'), false);
    });

    test('rejects malformed URLs', () {
      expect(UrlHelpers.isYouTubeUrl('not a url'), false);
      expect(UrlHelpers.isYouTubeUrl(''), false);
      expect(UrlHelpers.isYouTubeUrl('youtube.com'), false);
    });

    test('validates video ID with at least 11 characters', () {
      // Valid: 11 or more characters (strict validation happens on backend)
      expect(UrlHelpers.isYouTubeUrl('https://youtube.com/watch?v=dQw4w9WgXcQ'), true);
      expect(UrlHelpers.isYouTubeUrl('https://youtu.be/abc123DEF45'), true);
      
      // Invalid: fewer than 11 characters
      expect(UrlHelpers.isYouTubeUrl('https://youtube.com/watch?v=short'), false);
      
      // Note: URLs with >11 chars pass client validation
      // Backend will handle exact 11-char validation
    });
  });

  group('UrlHelpers.extractYouTubeId', () {
    test('extracts video ID from standard YouTube URLs', () {
      expect(UrlHelpers.extractYouTubeId('https://www.youtube.com/watch?v=dQw4w9WgXcQ'), 'dQw4w9WgXcQ');
      expect(UrlHelpers.extractYouTubeId('https://youtube.com/watch?v=abc123DEF45'), 'abc123DEF45');
    });

    test('extracts video ID from youtu.be URLs', () {
      expect(UrlHelpers.extractYouTubeId('https://youtu.be/dQw4w9WgXcQ'), 'dQw4w9WgXcQ');
      expect(UrlHelpers.extractYouTubeId('http://youtu.be/abc123DEF45'), 'abc123DEF45');
    });

    test('extracts video ID from mobile URLs', () {
      expect(UrlHelpers.extractYouTubeId('https://m.youtube.com/watch?v=dQw4w9WgXcQ'), 'dQw4w9WgXcQ');
    });

    test('extracts video ID with additional query parameters', () {
      expect(UrlHelpers.extractYouTubeId('https://youtube.com/watch?v=dQw4w9WgXcQ&t=30s'), 'dQw4w9WgXcQ');
      expect(UrlHelpers.extractYouTubeId('https://youtube.com/watch?v=dQw4w9WgXcQ&list=PLxyz'), 'dQw4w9WgXcQ');
    });

    test('returns null for non-YouTube URLs', () {
      expect(UrlHelpers.extractYouTubeId('https://vimeo.com/123456'), null);
      expect(UrlHelpers.extractYouTubeId('https://google.com'), null);
    });

    test('returns null for malformed URLs', () {
      expect(UrlHelpers.extractYouTubeId('not a url'), null);
      expect(UrlHelpers.extractYouTubeId(''), null);
    });

    test('handles URLs with hyphens and underscores in video ID', () {
      expect(UrlHelpers.extractYouTubeId('https://youtube.com/watch?v=abc-DEF_123'), 'abc-DEF_123');
      expect(UrlHelpers.extractYouTubeId('https://youtu.be/xyz-ABC_789'), 'xyz-ABC_789');
    });
  });
}
