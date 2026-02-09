import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/url_helpers.dart';
import '../services/api_service.dart';
import 'link_generated_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateLink() async {
    final url = _urlController.text.trim();

    // Validate URL
    if (url.isEmpty) {
      setState(() {
        _errorMessage = 'Please paste a YouTube link';
      });
      return;
    }

    if (!UrlHelpers.isYouTubeUrl(url)) {
      setState(() {
        _errorMessage = 'Please enter a valid YouTube URL';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      // Track event
      ApiService.trackEvent('link_creation_started', {'url': url});

      // Call API
      final result = await ApiService.shortenUrl(url);

      // Track success
      ApiService.trackEvent('link_created', {
        'shortCode': result['shortCode'],
        'originalUrl': url,
      });

      if (!mounted) return;

      // Navigate to success screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LinkGeneratedScreen(
            shortUrl: result['shortUrl'],
            shortCode: result['shortCode'],
          ),
        ),
      );

      // Clear input
      _urlController.clear();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });

      ApiService.trackEvent('link_creation_failed', {
        'error': e.toString(),
        'url': url,
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handlePaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      _urlController.text = data.text!;
      setState(() {
        _errorMessage = null;
      });
    }
  }

  void _handleClear() {
    _urlController.clear();
    setState(() {
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValidUrl = _urlController.text.trim().isNotEmpty &&
        UrlHelpers.isYouTubeUrl(_urlController.text);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const SizedBox(height: 40),
              Text(
                'OpenRight',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create smart links that open directly in the YouTube app',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 48),

              // URL Input
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: 'Paste your YouTube link here',
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  suffixIcon: _urlController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _handleClear,
                        )
                      : IconButton(
                          icon: const Icon(Icons.content_paste),
                          onPressed: _handlePaste,
                        ),
                ),
                onChanged: (value) {
                  setState(() {
                    _errorMessage = null;
                  });
                },
              ),

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Create Button
              FilledButton(
                onPressed: (!isValidUrl || _isLoading) ? null : _handleCreateLink,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Create Smart Link',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),

              const SizedBox(height: 24),

              // Helper text
              Text(
                'Your shortened link will automatically open in the YouTube app when shared',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const Spacer(),

              // Footer
              Text(
                'Fast · Trustworthy · Works on all platforms',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
