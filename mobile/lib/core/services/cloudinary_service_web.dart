// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:convert';
import '../config/app_config.dart';

Future<String?> uploadImage(String base64Str) async {
  try {
    // Cloudinary unsigned upload endpoint for images
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
      html.window.console.warn('Cloudinary image upload failed with status ${req.status}: ${req.responseText}');
    }
  } catch (e) {
    html.window.console.warn('Error uploading image to Cloudinary: $e');
  }
  return null;
}

Future<String?> uploadVideo(String blobUrl) async {
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
    formData.append('upload_preset', AppConfig.cloudinaryVideoUploadPreset);

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
      html.window.console.warn('Cloudinary video upload failed with status ${req.status}: ${req.responseText}');
    }
  } catch (e) {
    html.window.console.warn('Error uploading video to Cloudinary: $e');
  }
  return null;
}
