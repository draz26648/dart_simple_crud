import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../core/interfaces/i_auth_service.dart';
import '../core/interfaces/i_file_service.dart';

class AuthController {
  final IAuthService _authService;
  final IFileService _fileService;

  AuthController(this._authService, this._fileService);

  Router get router {
    final router = Router();

    router.post('/login', (Request request) async {
      try {
        final payload = await request.readAsString();
        final Map<String, dynamic> body = json.decode(payload);
        
        if (!body.containsKey('email') || !body.containsKey('password')) {
          return Response(HttpStatus.badRequest,
            body: json.encode({
              'error': 'Email and password are required'
            }),
            headers: {'content-type': 'application/json'},
          );
        }

        final result = await _authService.login(
          body['email'] as String,
          body['password'] as String,
        );

        return Response.ok(
          json.encode(result),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response(HttpStatus.unauthorized,
          body: json.encode({
            'error': e.toString()
          }),
          headers: {'content-type': 'application/json'},
        );
      }
    });

    router.post('/register', (Request request) async {
      try {
        final contentType = request.headers['content-type'];
        if (contentType == null || !contentType.startsWith('multipart/form-data')) {
          return Response(HttpStatus.badRequest,
            body: json.encode({
              'error': 'Invalid content type. Must be multipart/form-data'
            }),
            headers: {'content-type': 'application/json'},
          );
        }

        final body = await request.read().toList();
        if (body.isEmpty) {
          return Response(HttpStatus.badRequest,
            body: json.encode({
              'error': 'No data provided'
            }),
            headers: {'content-type': 'application/json'},
          );
        }

        // Parse multipart form data
        final boundary = contentType.split('boundary=')[1];
        final parts = body.expand((i) => i).toList();
        final String rawData = String.fromCharCodes(parts);
        final formDataParts = rawData.split('--$boundary');

        Map<String, dynamic> formData = {};
        List<int>? imageBytes;
        String? fileName;

        for (var part in formDataParts) {
          if (part.contains('Content-Disposition: form-data;')) {
            if (part.contains('name="profile_image"') && part.contains('filename=')) {
              // Extract filename
              final filenameMatch = RegExp(r'filename="([^"]+)"').firstMatch(part);
              if (filenameMatch != null) {
                fileName = filenameMatch.group(1);
                print('Found file upload with name: $fileName');
                
                // Find the start of the binary data (after the double CRLF)
                final headerEnd = part.indexOf('\r\n\r\n');
                if (headerEnd != -1) {
                  // Convert the binary part to bytes, excluding the trailing boundary
                  final binaryData = part.substring(headerEnd + 4);
                  // Remove the last \r\n if present
                  final cleanBinaryData = binaryData.endsWith('\r\n') 
                      ? binaryData.substring(0, binaryData.length - 2)
                      : binaryData;
                      
                  // Convert to bytes and validate
                  imageBytes = cleanBinaryData.codeUnits;
                  if (imageBytes.isEmpty) {
                    print('Warning: Image bytes is empty');
                  } else {
                    print('Successfully extracted image data:');
                    print('- File name: $fileName');
                    print('- Data length: ${imageBytes.length} bytes');
                    print('- First few bytes: ${imageBytes.take(10).toList()}');
                  }
                } else {
                  print('Error: Could not find start of binary data');
                }
              } else {
                print('Error: Could not extract filename from header');
              }
            } else {
              // This is a regular form field
              final match = RegExp(r'name="([^"]+)"').firstMatch(part);
              if (match != null) {
                final name = match.group(1)!;
                final valueStart = part.indexOf('\r\n\r\n') + 4;
                final valueEnd = part.lastIndexOf('\r\n');
                if (valueStart > 0 && valueEnd > valueStart) {
                  formData[name] = part.substring(valueStart, valueEnd);
                }
              }
            }
          }
        }

        // Validate required fields
        if (!formData.containsKey('name') || 
            !formData.containsKey('email') || 
            !formData.containsKey('password')) {
          return Response(HttpStatus.badRequest,
            body: json.encode({
              'error': 'Name, email and password are required'
            }),
            headers: {'content-type': 'application/json'},
          );
        }

        // Save image if provided
        String? profileImagePath;
        if (imageBytes != null && fileName != null) {
          try {
            print('Attempting to save image: $fileName');
            print('Image bytes length: ${imageBytes.length}');
            profileImagePath = await _fileService.saveProfileImage(fileName, imageBytes);
            if (profileImagePath == null) {
              print('Failed to save image: profileImagePath is null');
              return Response(HttpStatus.internalServerError,
                body: json.encode({
                  'error': 'Failed to save profile image. Please check server logs.'
                }),
                headers: {'content-type': 'application/json'},
              );
            }
          } catch (e) {
            print('Error saving image: $e');
            return Response(HttpStatus.internalServerError,
              body: json.encode({
                'error': 'Failed to save profile image: ${e.toString()}'
              }),
              headers: {'content-type': 'application/json'},
            );
          }
        }

        final result = await _authService.register(
          formData['name'],
          formData['email'],
          formData['password'],
          gender: formData['gender'],
          age: formData['age'] != null ? int.parse(formData['age']) : null,
          mobileNumber: formData['mobile_number'],
          profileImagePath: profileImagePath,
        );

        return Response.ok(
          json.encode(result),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response(HttpStatus.badRequest,
          body: json.encode({
            'error': e.toString()
          }),
          headers: {'content-type': 'application/json'},
        );
      }
    });

    router.post('/logout', (Request request) async {
      try {
        final authHeader = request.headers['authorization'];
        if (authHeader == null || !authHeader.startsWith('Bearer ')) {
          return Response(HttpStatus.unauthorized,
            body: json.encode({
              'error': 'No token provided'
            }),
            headers: {'content-type': 'application/json'},
          );
        }

        final token = authHeader.substring(7);
        await _authService.logout(token);

        return Response.ok(
          json.encode({
            'message': 'Logged out successfully'
          }),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response(HttpStatus.internalServerError,
          body: json.encode({
            'error': e.toString()
          }),
          headers: {'content-type': 'application/json'},
        );
      }
    });

    return router;
  }
}
