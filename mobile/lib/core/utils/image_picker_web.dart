// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'web_video_player.dart';

Future<String?> _compressImage(html.File file) {
  final completer = Completer<String?>();
  final reader = html.FileReader();
  reader.readAsDataUrl(file);
  reader.onLoadEnd.listen((e) {
    final dataUrl = reader.result as String;
    final img = html.ImageElement()..src = dataUrl;
    img.onLoad.listen((_) {
      // Calculate new size keeping aspect ratio
      const maxDim = 800;
      int width = img.width ?? 0;
      int height = img.height ?? 0;
      if (width == 0 || height == 0) {
        completer.complete(dataUrl); // Fallback
        return;
      }
      
      if (width > maxDim || height > maxDim) {
        if (width > height) {
          height = (height * maxDim / width).round();
          width = maxDim;
        } else {
          width = (width * maxDim / height).round();
          height = maxDim;
        }
      }
      
      final canvas = html.CanvasElement(width: width, height: height);
      final ctx = canvas.context2D;
      ctx.drawImageScaled(img, 0, 0, width, height);
      
      // Export as compressed JPEG (70% quality)
      try {
        final compressedDataUrl = canvas.toDataUrl('image/jpeg', 0.7);
        completer.complete(compressedDataUrl);
      } catch (err) {
        completer.complete(dataUrl); // Fallback if security/canvas error
      }
    });
    img.onError.listen((_) {
      completer.complete(dataUrl); // Fallback
    });
  });
  reader.onError.listen((_) {
    completer.complete(null);
  });
  return completer.future;
}

Future<String?> pickImageFromGallery() async {
  final completer = Completer<String?>();
  final input = html.InputElement(type: 'file')..accept = 'image/*';
  
  // Trigger file selection in browser
  input.click();
  
  input.onChange.listen((e) {
    final files = input.files;
    if (files == null || files.isEmpty) {
      if (!completer.isCompleted) completer.complete(null);
      return;
    }
    
    final file = files[0];
    _compressImage(file).then((result) {
      if (!completer.isCompleted) {
        completer.complete(result);
      }
    });
  });
  
  return completer.future;
}

Future<String?> captureImageFromCamera() async {
  final completer = Completer<String?>();
  final input = html.InputElement(type: 'file')
    ..accept = 'image/*'
    ..setAttribute('capture', 'environment');
  
  // Trigger file/camera selection in browser
  input.click();
  
  input.onChange.listen((e) {
    final files = input.files;
    if (files == null || files.isEmpty) {
      if (!completer.isCompleted) completer.complete(null);
      return;
    }
    
    final file = files[0];
    _compressImage(file).then((result) {
      if (!completer.isCompleted) {
        completer.complete(result);
      }
    });
  });
  
  return completer.future;
}

Future<String?> pickVideoFromGallery() async {
  final completer = Completer<String?>();
  final input = html.InputElement(type: 'file')..accept = 'video/*';

  input.click();

  input.onChange.listen((e) {
    final files = input.files;
    if (files == null || files.isEmpty) {
      if (!completer.isCompleted) completer.complete(null);
      return;
    }

    final file = files[0];
    try {
      final objectUrl = html.Url.createObjectUrl(file);
      localActiveBlobs.add(objectUrl); // Track the active blob in the current session
      if (!completer.isCompleted) {
        completer.complete(objectUrl);
      }
    } catch (err) {
      if (!completer.isCompleted) {
        completer.complete(file.name); // Fallback to filename if blob fails
      }
    }
  });

  return completer.future;
}

Future<String?> compressBase64Image(String base64Str, {int maxDim = 500, double quality = 0.6}) async {
  final completer = Completer<String?>();
  
  final cleanBase64 = base64Str.contains(',')
      ? base64Str
      : 'data:image/png;base64,$base64Str';

  final img = html.ImageElement()..src = cleanBase64;
  img.onLoad.listen((_) {
    int width = img.width ?? 0;
    int height = img.height ?? 0;
    if (width == 0 || height == 0) {
      completer.complete(base64Str);
      return;
    }
    
    if (width > maxDim || height > maxDim) {
      if (width > height) {
        height = (height * maxDim / width).round();
        width = maxDim;
      } else {
        width = (width * maxDim / height).round();
        height = maxDim;
      }
    }
    
    final canvas = html.CanvasElement(width: width, height: height);
    final ctx = canvas.context2D;
    ctx.drawImageScaled(img, 0, 0, width, height);
    
    try {
      final compressed = canvas.toDataUrl('image/jpeg', quality);
      completer.complete(compressed);
    } catch (e) {
      completer.complete(base64Str); // Fallback
    }
  });
  
  img.onError.listen((_) {
    completer.complete(base64Str); // Fallback
  });
  
  return completer.future;
}
