import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import '../core/interfaces/i_file_service.dart';

class FileService implements IFileService {
  static const String uploadDirectory = 'uploads';
  static const String profileImagesDirectory = 'profile_images';
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = [
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/gif'
  ];

  @override
  Future<void> initialize() async {
    try {
      // Create required directories if they don't exist
      final uploadsPath = path.join(Directory.current.path, uploadDirectory);
      final profileImagesPath = path.join(uploadsPath, profileImagesDirectory);
      
      await Directory(uploadsPath).create(recursive: true);
      await Directory(profileImagesPath).create(recursive: true);
    } catch (e) {
      throw Exception('Failed to initialize file service: ${e.toString()}');
    }
  }

  @override
  bool isValidImageFile(String fileName) {
    try {
      // Check if the file is an image based on its MIME type
      final mimeType = lookupMimeType(fileName.toLowerCase());
      print('Checking file type: $fileName, MIME type: $mimeType');
      
      // Check file extension
      final extension = path.extension(fileName).toLowerCase();
      final isValidExtension = ['.jpg', '.jpeg', '.png', '.gif'].contains(extension);
      print('File extension: $extension, Valid extension: $isValidExtension');
      
      // Check MIME type
      final isValidMime = mimeType != null && allowedImageTypes.contains(mimeType);
      print('Valid MIME type: $isValidMime');
      
      return isValidExtension && (mimeType == null || isValidMime);
    } catch (e) {
      print('Error checking file type: $e');
      return false;
    }
  }

  @override
  String generateUniqueFileName(String originalFileName) {
    // Generate a unique filename using timestamp and random string
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(1000000).toString().padLeft(6, '0');
    final sanitizedFileName = path.basename(originalFileName).replaceAll(RegExp(r'[^a-zA-Z0-9.-]'), '_');
    final extension = path.extension(sanitizedFileName).toLowerCase();
    
    if (!allowedImageTypes.any((type) => type.endsWith(extension.replaceFirst('.', '')))) {
      throw Exception('Invalid file extension. Allowed types: jpg, png, gif');
    }

    return '$timestamp$random$extension';
  }

  @override
  Future<String?> saveProfileImage(String fileName, List<int> fileBytes) async {
    try {
      print('Starting to save profile image: $fileName');
      print('File size: ${fileBytes.length} bytes');

      // Validate file size
      if (fileBytes.length > maxFileSizeBytes) {
        print('File size exceeds limit: ${fileBytes.length} > $maxFileSizeBytes');
        throw Exception('File size exceeds maximum limit of 5MB');
      }

      // Validate file type
      final mimeType = lookupMimeType(fileName);
      print('Detected MIME type: $mimeType');
      if (!isValidImageFile(fileName)) {
        print('Invalid file type. MIME type: $mimeType');
        throw Exception('Invalid file type. Only JPG, PNG, and GIF images are allowed.');
      }

      // Generate unique filename and save file
      final uniqueFileName = generateUniqueFileName(fileName);
      print('Generated unique filename: $uniqueFileName');
      
      final relativePath = path.join(profileImagesDirectory, uniqueFileName);
      final fullPath = path.join(Directory.current.path, uploadDirectory, relativePath);
      print('Full path for saving: $fullPath');

      // Ensure the target directory exists
      final directory = Directory(path.dirname(fullPath));
      print('Checking directory: ${directory.path}');
      if (!await directory.exists()) {
        print('Creating directory: ${directory.path}');
        await directory.create(recursive: true);
      }

      // Write file with proper permissions
      print('Writing file to disk...');
      final file = File(fullPath);
      await file.writeAsBytes(fileBytes, mode: FileMode.writeOnly);
      print('File written successfully');

      // Return relative path for database storage
      return relativePath;
    } catch (e, stackTrace) {
      print('Error saving file: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  @override
  Future<bool> deleteProfileImage(String? filePath) async {
    if (filePath == null) return true;

    try {
      // Validate file path to prevent directory traversal
      final normalizedPath = path.normalize(filePath);
      if (normalizedPath.contains('..')) {
        throw Exception('Invalid file path');
      }

      // Delete file if it exists
      final fullPath = path.join(Directory.current.path, uploadDirectory, normalizedPath);
      final file = File(fullPath);
      
      if (await file.exists()) {
        await file.delete();
      }
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }
}
