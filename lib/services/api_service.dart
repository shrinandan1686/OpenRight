import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io'; // For SocketException
import 'dart:async'; // For TimeoutException
import 'package:flutter/foundation.dart'; // For debugPrint

class ApiService {
  static const String _baseUrl = 'https://links.travelerstab.com';
  static const Duration _timeout = Duration(seconds: 10);
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 1);

  /// Shorten a YouTube URL with retry logic
  static Future<Map<String, dynamic>> shortenUrl(String url) async {
    return _retryRequest(() => _shortenUrlOnce(url));
  }

  /// Internal method to shorten URL (single attempt)
  static Future<Map<String, dynamic>> _shortenUrlOnce(String url) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/shorten'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'url': url}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 429) {
        // Rate limit exceeded
        final errorData = json.decode(response.body);
        throw ApiException(
          'Too many requests. Please wait a minute.',
          code: 'RATE_LIMIT_EXCEEDED',
          statusCode: 429,
        );
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        // Client error
        final errorData = json.decode(response.body);
        throw ApiException(
          errorData['error'] ?? 'Invalid request',
          code: 'CLIENT_ERROR',
          statusCode: response.statusCode,
        );
      } else {
        // Server error
        throw ApiException(
          'Server error. Please try again.',
          code: 'SERVER_ERROR',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw ApiException(
        'Request timed out. Please check your connection.',
        code: 'TIMEOUT',
      );
    } on SocketException {
      throw ApiException(
        'No internet connection',
        code: 'NO_INTERNET',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Failed to create link. Please try again.',
        code: 'UNKNOWN_ERROR',
        originalError: e,
      );
    }
  }

  /// Retry wrapper for API requests
  static Future<T> _retryRequest<T>(Future<T> Function() request) async {
    int attempts = 0;
    
    while (attempts < _maxRetries) {
      try {
        return await request();
      } on ApiException catch (e) {
        attempts++;
        
        // Don't retry client errors (400-499) except for timeouts
        if (e.statusCode != null && 
            e.statusCode! >= 400 && 
            e.statusCode! < 500 && 
            e.code != 'TIMEOUT') {
          rethrow;
        }
        
        // Don't retry rate limiting
        if (e.code == 'RATE_LIMIT_EXCEEDED') {
          rethrow;
        }
        
        // Last attempt - rethrow error
        if (attempts >= _maxRetries) {
          rethrow;
        }
        
        // Wait before retrying
        await Future.delayed(_retryDelay * attempts);
      }
    }
    
    throw ApiException('Maximum retries exceeded', code: 'MAX_RETRIES');
  }

  /// Track analytics event (fire-and-forget, no retries)
  static Future<void> trackEvent(String event, Map<String, dynamic> data) async {
    try {
      await http
          .post(
            Uri.parse('$_baseUrl/api/analytics'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'event': event, 'data': data}),
          )
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      // Silent failure for analytics
      debugPrint('Analytics error: $e');
    }
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final String code;
  final int? statusCode;
  final dynamic originalError;

  ApiException(
    this.message, {
    required this.code,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => message;
}
