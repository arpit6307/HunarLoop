// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

// Keep track of already registered view factories to prevent duplicate registration assertion errors
final Set<String> _registeredViews = {};

// Keep track of locally created active blob URLs in the current session
final Set<String> localActiveBlobs = {};

Widget createWebVideoPlayer(String viewId, String url) {
  return WebVideoPlayer(viewId: viewId, url: url);
}

void _registerViewFactory(String viewId, String url) {
  if (!_registeredViews.contains(viewId)) {
    _registeredViews.add(viewId);
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
      final videoElement = html.VideoElement()
        ..autoplay = true
        ..controls = true
        ..muted = true // Autoplay is guaranteed when muted!
        ..src = url // Direct src assignment for reliable HTML5 video loading
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none'
        ..style.backgroundColor = 'black';

      videoElement.load();
      return videoElement;
    });
  }
}

class WebVideoPlayer extends StatefulWidget {
  final String viewId;
  final String url;

  const WebVideoPlayer({super.key, required this.viewId, required this.url});

  @override
  State<WebVideoPlayer> createState() => _WebVideoPlayerState();
}

class _WebVideoPlayerState extends State<WebVideoPlayer> {
  late String _resolvedUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _resolveUrl();
  }

  void _resolveUrl() {
    final url = widget.url;
    if (url.startsWith('blob:')) {
      if (localActiveBlobs.contains(url)) {
        // Valid local blob from the current session
        setState(() {
          _resolvedUrl = url;
          _isLoading = false;
        });
      } else {
        // Dead blob from previous session or another user. Use fallback to avoid ERR_FILE_NOT_FOUND.
        setState(() {
          _resolvedUrl = 'https://www.w3schools.com/html/mov_bbb.mp4';
          _isLoading = false;
        });
      }
    } else {
      // Normal network URL
      setState(() {
        _resolvedUrl = url;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
      );
    }

    final resolvedViewId = '${widget.viewId}-${_resolvedUrl.hashCode}';
    _registerViewFactory(resolvedViewId, _resolvedUrl);

    return HtmlElementView(viewType: resolvedViewId);
  }
}
