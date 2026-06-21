// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:convert';
import '../config/app_config.dart';

Future<String?> uploadImage(String base64Str) async {
  if (AppConfig.cloudinaryCloudName.isEmpty || AppConfig.cloudinaryUploadPreset.isEmpty) {
    throw Exception('CLOUDINARY NOT CONFIGUED: Cloud name or upload preset is empty inside app_config.dart');
  }

  try {
    final url = 'https://api.cloudinary.com/v1_1/${AppConfig.cloudinaryCloudName}/image/upload';

    final formData = html.FormData();
    formData.append('file', base64Str);
    formData.append('upload_preset', AppConfig.cloudinaryUploadPreset);

    final req = await html.HttpRequest.request(
      url,
      method: 'POST',
      sendData: formData,
    );

    if (req.status == 200 || req.status == 201) {
      final responseData = jsonDecode(req.responseText ?? '{}');
      final secureUrl = responseData['secure_url'] as String?;
      html.window.console.log('Successfully uploaded image to Cloudinary: $secureUrl');
      return secureUrl;
    } else {
      String details = 'Unknown Error';
      try {
        final responseData = jsonDecode(req.responseText ?? '{}');
        if (responseData['error'] != null && responseData['error']['message'] != null) {
          details = responseData['error']['message'];
        } else {
          details = req.responseText ?? 'Unknown Error';
        }
      } catch (_) {
        details = req.responseText ?? 'Unknown Error';
      }
      throw Exception('Cloudinary Image Upload Failed: $details');
    }
  } catch (e) {
    html.window.console.warn('Error uploading image to Cloudinary: $e');
    rethrow;
  }
}

Future<String?> uploadVideo(String blobUrl) async {
  if (AppConfig.cloudinaryCloudName.isEmpty || AppConfig.cloudinaryUploadPreset.isEmpty) {
    throw Exception('CLOUDINARY NOT CONFIGUED: Cloud name or upload preset is empty inside app_config.dart');
  }

  try {
    // 1. Fetch the local Blob object from the blob URL
    final fetchReq = await html.HttpRequest.request(
      blobUrl,
      method: 'GET',
      responseType: 'blob',
    );
    final html.Blob blob = fetchReq.response;

    // Cloudinary unsigned upload endpoint for videos
    final url = 'https://api.cloudinary.com/v1_1/${AppConfig.cloudinaryCloudName}/video/upload';

    final formData = html.FormData();
    formData.appendBlob('file', blob, 'video.mp4');
    formData.append('upload_preset', AppConfig.cloudinaryUploadPreset);

    final req = await html.HttpRequest.request(
      url,
      method: 'POST',
      sendData: formData,
    );

    if (req.status == 200 || req.status == 201) {
      final responseData = jsonDecode(req.responseText ?? '{}');
      final secureUrl = responseData['secure_url'] as String?;
      html.window.console.log('Successfully uploaded video to Cloudinary: $secureUrl');
      return secureUrl;
    } else {
      String details = 'Unknown Error';
      try {
        final responseData = jsonDecode(req.responseText ?? '{}');
        if (responseData['error'] != null && responseData['error']['message'] != null) {
          details = responseData['error']['message'];
        } else {
          details = req.responseText ?? 'Unknown Error';
        }
      } catch (_) {
        details = req.responseText ?? 'Unknown Error';
      }
      throw Exception('Cloudinary Video Upload Failed: $details');
    }
  } catch (e) {
    html.window.console.warn('Error uploading video to Cloudinary: $e');
    rethrow;
  }
}
