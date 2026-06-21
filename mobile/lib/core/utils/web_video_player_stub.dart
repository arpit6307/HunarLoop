import 'package:flutter/material.dart';

final Set<String> localActiveBlobs = {};

Widget createWebVideoPlayer(String viewId, String url) {
  return const Center(
    child: Text(
      'VIDEO PLAYER NOT SUPPORTED ON THIS PLATFORM',
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
    ),
  );
}
