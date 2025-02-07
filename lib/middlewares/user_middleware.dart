import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../core/interfaces/i_user_service.dart';
import '../services/auth_service.dart';
import '../core/di/service_locator.dart';

class UserMiddleware {
  final IUserService _userService;

  UserMiddleware(this._userService);

  Middleware checkUserExists() {
    return (Handler innerHandler) {
      return (Request request) async {
        try {
          final params = request.url.pathSegments;
          if (params.isEmpty) {
            return Response.notFound(
              json.encode({'error': 'User ID is required'}),
              headers: {'content-type': 'application/json'},
            );
          }

          final userId = int.tryParse(params.last);
          if (userId == null) {
            return Response.badRequest(
              body: json.encode({'error': 'Invalid user ID format'}),
              headers: {'content-type': 'application/json'},
            );
          }

          final user = await _userService.getUserById(userId);
          if (user == null) {
            return Response.notFound(
              json.encode({'error': 'User not found'}),
              headers: {'content-type': 'application/json'},
            );
          }

          final updatedRequest = request.change(context: {'user': user});
          return innerHandler(updatedRequest);
        } catch (e) {
          print('Error in checkUserExists middleware: ${e.toString()}');
          return Response.internalServerError(
            body: json.encode({'error': 'Internal server error'}),
            headers: {'content-type': 'application/json'},
          );
        }
      };
    };
  }

  Middleware validateUserData() {
    return (Handler innerHandler) {
      return (Request request) async {
        if (request.method != 'POST' && request.method != 'PUT') {
          return innerHandler(request);
        }

        try {
          final payload = await request.readAsString();
          final data = json.decode(payload);

          final requiredFields = ['name', 'email'];
          for (final field in requiredFields) {
            if (!data.containsKey(field) || data[field].toString().isEmpty) {
              return Response.badRequest(
                body: json.encode({'error': '$field is required'}),
                headers: {'content-type': 'application/json'},
              );
            }
          }

          if (!_isValidEmail(data['email'])) {
            return Response.badRequest(
              body: json.encode({'error': 'Invalid email format'}),
              headers: {'content-type': 'application/json'},
            );
          }

          if (data.containsKey('age')) {
            final age = int.tryParse(data['age'].toString());
            if (age == null || age < 0 || age > 120) {
              return Response.badRequest(
                body: json.encode({'error': 'Invalid age value'}),
                headers: {'content-type': 'application/json'},
              );
            }
          }

          return innerHandler(request);
        } catch (e) {
          print('Error in validateUserData middleware: ${e.toString()}');
          return Response.badRequest(
            body: json.encode({'error': 'Invalid request data format'}),
            headers: {'content-type': 'application/json'},
          );
        }
      };
    };
  }

  Middleware checkUserPermissions() {
    return (Handler innerHandler) {
      return (Request request) async {
        try {
          final authHeader = request.headers['authorization'];
          if (authHeader == null) {
            return Response.forbidden(
              json.encode({'error': 'No authorization token provided'}),
              headers: {'content-type': 'application/json'},
            );
          }

          final token = authHeader.replaceFirst('Bearer ', '');
          final authService = serviceLocator<AuthService>();
          
          try {
            final userId = await authService.verifyToken(token);
            final user = await _userService.getUserById(userId);
            
            if (user == null) {
              return Response.forbidden(
                json.encode({'error': 'User not found'}),
                headers: {'content-type': 'application/json'},
              );
            }

            final updatedRequest = request.change(context: {
              'userId': userId,
              'user': user,
            });

            return innerHandler(updatedRequest);
          } catch (e) {
            return Response.forbidden(
              json.encode({'error': 'Invalid or expired token'}),
              headers: {'content-type': 'application/json'},
            );
          }
        } catch (e) {
          print('Error in checkUserPermissions middleware: ${e.toString()}');
          return Response.internalServerError(
            body: json.encode({'error': 'Internal server error'}),
            headers: {'content-type': 'application/json'},
          );
        }
      };
    };
  }

  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegExp.hasMatch(email);
  }
}
