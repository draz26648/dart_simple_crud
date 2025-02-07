import 'package:shelf/shelf.dart';
import '../core/interfaces/i_file_service.dart';
import 'dart:convert';
import 'package:mime/mime.dart';

class FileMiddleware {
  final IFileService _fileService;
  final int _maxFileSize = 5 * 1024 * 1024; // 5MB
  final Set<String> _allowedMimeTypes = {
    'image/jpeg',
    'image/png',
    'image/gif',
  };

  FileMiddleware(this._fileService);

  Middleware validateFileUpload() {
    return (Handler innerHandler) {
      return (Request request) async {
        try {
          if (!request.headers.containsKey('content-type') ||
              !request.headers['content-type']!.contains('multipart/form-data')) {
            return Response.badRequest(
              body: json.encode({
                'error': 'Invalid content type. Must be multipart/form-data',
              }),
              headers: {'content-type': 'application/json'},
            );
          }

          final contentLength = request.headers['content-length'];
          if (contentLength != null) {
            final size = int.tryParse(contentLength);
            if (size != null && size > _maxFileSize) {
              return Response.badRequest(
                body: json.encode({
                  'error': 'File size exceeds the maximum limit of 5MB',
                }),
                headers: {'content-type': 'application/json'},
              );
            }
          }

          return innerHandler(request);
        } catch (e) {
          print('Error in validateFileUpload middleware: ${e.toString()}');
          return Response.internalServerError(
            body: json.encode({
              'error': 'Error processing file upload',
            }),
            headers: {'content-type': 'application/json'},
          );
        }
      };
    };
  }

  Middleware validateFileType() {
    return (Handler innerHandler) {
      return (Request request) async {
        try {
          final fileName = request.url.queryParameters['filename'];
          if (fileName == null) {
            return Response.badRequest(
              body: json.encode({
                'error': 'Filename is required',
              }),
              headers: {'content-type': 'application/json'},
            );
          }

          // Check file extension
          if (!_fileService.isValidImageFile(fileName)) {
            return Response.badRequest(
              body: json.encode({
                'error': 'Invalid file type. Only image files are allowed (jpg, jpeg, png, gif)',
              }),
              headers: {'content-type': 'application/json'},
            );
          }

          // Check MIME type
          final mimeType = lookupMimeType(fileName);
          if (mimeType == null || !_allowedMimeTypes.contains(mimeType)) {
            return Response.badRequest(
              body: json.encode({
                'error': 'Invalid file type. Only images are allowed.',
              }),
              headers: {'content-type': 'application/json'},
            );
          }

          // Add file info to request context
          final updatedRequest = request.change(
            context: {
              'fileName': fileName,
              'mimeType': mimeType,
            },
          );

          return innerHandler(updatedRequest);
        } catch (e) {
          print('Error in validateFileType middleware: ${e.toString()}');
          return Response.internalServerError(
            body: json.encode({
              'error': 'Error validating file type',
            }),
            headers: {'content-type': 'application/json'},
          );
        }
      };
    };
  }

  Middleware sanitizeFileName() {
    return (Handler innerHandler) {
      return (Request request) async {
        try {
          final fileName = request.url.queryParameters['filename'];
          if (fileName == null) {
            return innerHandler(request);
          }

          // Remove potentially dangerous characters
          final sanitizedFileName = fileName
              .replaceAll(RegExp(r'[^\w\s\-\.]'), '')
              .replaceAll(RegExp(r'\s+'), '_');

          // Generate unique filename
          final uniqueFileName = _fileService.generateUniqueFileName(sanitizedFileName);

          // Add sanitized filename to request context
          final updatedRequest = request.change(
            context: {
              'sanitizedFileName': uniqueFileName,
            },
          );

          return innerHandler(updatedRequest);
        } catch (e) {
          print('Error in sanitizeFileName middleware: ${e.toString()}');
          return Response.internalServerError(
            body: json.encode({
              'error': 'Error processing filename',
            }),
            headers: {'content-type': 'application/json'},
          );
        }
      };
    };
  }
}
