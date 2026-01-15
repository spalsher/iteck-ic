import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'auth_service.dart';
import '../config/environment.dart';

class MediaService {
  static final String baseUrl = Environment.baseUrl;
  final Dio _dio = Dio();
  final ImagePicker _picker = ImagePicker();
  final AuthService _authService;

  MediaService(this._authService);

  // Pick image from gallery
  Future<File?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  // Pick image from camera
  Future<File?> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    }
  }

  // Pick video
  Future<File?> pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      
      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      print('Error picking video: $e');
      return null;
    }
  }

  // Record video
  Future<File?> recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );
      
      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      print('Error recording video: $e');
      return null;
    }
  }

  // Upload media file
  Future<Map<String, dynamic>> uploadMedia(File file) async {
    try {
      final token = _authService.token;
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '$baseUrl/media/upload',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        onSendProgress: (sent, total) {
          final progress = (sent / total * 100).toStringAsFixed(0);
          print('Upload progress: $progress%');
        },
      );

      if (response.statusCode == 200) {
        return response.data['file'];
      } else {
        throw Exception('Upload failed');
      }
    } catch (e) {
      print('Error uploading media: $e');
      rethrow;
    }
  }

  // Download media file
  Future<File?> downloadMedia(String filename) async {
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/$filename';
      
      await _dio.download(
        '$baseUrl/media/$filename',
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            print('Download progress: $progress%');
          }
        },
      );

      return File(filePath);
    } catch (e) {
      print('Error downloading media: $e');
      return null;
    }
  }

  // Get media URL
  String getMediaUrl(String filename) {
    return '$baseUrl/media/$filename';
  }

  // Delete media file
  Future<bool> deleteMedia(String filename) async {
    try {
      final token = _authService.token;
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await _dio.delete(
        '$baseUrl/media/$filename',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting media: $e');
      return false;
    }
  }
}
