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

        final boundary = contentType.split('boundary=')[1];
        final bytes = await request.read().expand((e) => e).toList();
        final String rawData = String.fromCharCodes(bytes);
        final formDataParts = rawData.split('--$boundary');

        Map<String, String> formData = {};
        List<int>? imageBytes;
        String? fileName;

        for (var part in formDataParts) {
          if (part.trim().isEmpty) continue;
          
          if (part.contains('Content-Disposition: form-data;')) {
            if (part.contains('name="profile_image"')) {
              // Handle file upload
              final filenameMatch = RegExp(r'filename="([^"]+)"').firstMatch(part);
              if (filenameMatch != null) {
                fileName = filenameMatch.group(1);
                final headerEnd = part.indexOf('\r\n\r\n');
                if (headerEnd != -1) {
                  final binaryData = part.substring(headerEnd + 4);
                  final cleanBinaryData = binaryData.endsWith('\r\n') 
                      ? binaryData.substring(0, binaryData.length - 2)
                      : binaryData;
                  imageBytes = cleanBinaryData.codeUnits;
                }
              }
            } else {
              // Handle form fields
              final nameMatch = RegExp(r'name="([^"]+)"').firstMatch(part);
              if (nameMatch != null) {
                final fieldName = nameMatch.group(1)!;
                final headerEnd = part.indexOf('\r\n\r\n');
                if (headerEnd != -1) {
                  var fieldValue = part.substring(headerEnd + 4);
                  if (fieldValue.endsWith('\r\n')) {
                    fieldValue = fieldValue.substring(0, fieldValue.length - 2);
                  }
                  formData[fieldName] = fieldValue;
                }
              }
            }
          }
        }

        // Validate required fields
        final requiredFields = ['name', 'email', 'password'];
        final validationErrors = <String>[];

        for (final field in requiredFields) {
          if (!formData.containsKey(field) || formData[field]!.isEmpty) {
            validationErrors.add('$field is required');
          }
        }

        // Email validation
        if (formData.containsKey('email') && !_isValidEmail(formData['email']!)) {
          validationErrors.add('Invalid email format');
        }

        // Password strength validation
        if (formData.containsKey('password') && !_isStrongPassword(formData['password']!)) {
          validationErrors.add(
            'Password must be at least 8 characters long and contain letters, numbers, and special characters'
          );
        }

        // Age validation if provided
        if (formData.containsKey('age') && formData['age']!.isNotEmpty) {
          final age = int.tryParse(formData['age']!);
          if (age == null || age < 0 || age > 120) {
            validationErrors.add('Invalid age value');
          }
        }

        if (validationErrors.isNotEmpty) {
          return Response.badRequest(
            body: json.encode({
              'errors': validationErrors,
            }),
            headers: {'content-type': 'application/json'},
          );
        }

        String? profileImagePath;
        if (fileName != null && imageBytes != null) {
          profileImagePath = await _fileService.saveProfileImage(fileName, imageBytes);
        }

        final result = await _authService.register(
          formData['name']!,
          formData['email']!,
          formData['password']!,
          gender: formData['gender'],
          age: formData['age'] != null ? int.tryParse(formData['age']!) : null,
          mobileNumber: formData['mobileNumber'],
          profileImagePath: profileImagePath,
        );

        return Response.ok(
          json.encode(result),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        print('Registration error: ${e.toString()}');
        return Response.internalServerError(
          body: json.encode({
            'error': 'Failed to process registration'
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

  bool _isValidEmail(String email) {
    final emailRegexp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegexp.hasMatch(email);
  }

  bool _isStrongPassword(String password) {
    final passwordRegexp = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return passwordRegexp.hasMatch(password);
  }
}
