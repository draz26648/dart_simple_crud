import 'package:shelf/shelf.dart';
import '../core/interfaces/i_auth_service.dart';
import 'dart:convert';

class AuthMiddleware {
  final IAuthService _authService;
  final Map<String, _RateLimit> _rateLimits = {};
  static const int _maxAttempts = 5;
  static const Duration _resetDuration = Duration(minutes: 15);

  AuthMiddleware(this._authService);

  Middleware validateLoginData() {
    return (Handler innerHandler) {
      return (Request request) async {
        if (request.method != 'POST') {
          return innerHandler(request);
        }

        final contentType = request.headers['content-type'];
        // Skip validation for non-JSON requests (like multipart/form-data)
        if (contentType == null || !contentType.startsWith('application/json')) {
          return innerHandler(request);
        }

        try {
          final clientIp = _getClientIp(request);
          if (_isRateLimited(clientIp)) {
            return Response(
              429,
              body: json.encode({
                'error': 'Too many attempts. Please try again later.',
                'resetIn': _getResetTimeInMinutes(clientIp),
              }),
              headers: {'content-type': 'application/json'},
            );
          }

          final payload = await request.readAsString();
          final data = json.decode(payload);

          if (!data.containsKey('email') || !data.containsKey('password')) {
            _incrementAttempts(clientIp);
            return Response.badRequest(
              body: json.encode({
                'error': 'Email and password are required',
              }),
              headers: {'content-type': 'application/json'},
            );
          }

          if (!isValidEmail(data['email'])) {
            _incrementAttempts(clientIp);
            return Response.badRequest(
              body: json.encode({
                'error': 'Invalid email format',
              }),
              headers: {'content-type': 'application/json'},
            );
          }

          if (!isStrongPassword(data['password'])) {
            _incrementAttempts(clientIp);
            return Response.badRequest(
              body: json.encode({
                'error': 'Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, one number, and one special character',
              }),
              headers: {'content-type': 'application/json'},
            );
          }

          // Create a new request with the validated body
          final updatedRequest = request.change(
            body: payload,
          );

          return innerHandler(updatedRequest);
        } catch (e) {
          print('Error in validateLoginData middleware: ${e.toString()}');
          return Response.badRequest(
            body: json.encode({
              'error': 'Invalid request data',
            }),
            headers: {'content-type': 'application/json'},
          );
        }
      };
    };
  }

  Middleware validateRegistrationData() {
    return (Handler innerHandler) {
      return (Request request) async {
        if (request.method != 'POST') {
          return innerHandler(request);
        }

        final contentType = request.headers['content-type'];
        if (contentType == null || !contentType.startsWith('multipart/form-data')) {
          return Response.badRequest(
            body: json.encode({
              'error': 'Invalid content type. Must be multipart/form-data'
            }),
            headers: {'content-type': 'application/json'},
          );
        }

        // Pass the request to the handler since we'll validate the form data there
        return innerHandler(request);
      };
    };
  }

  bool isValidEmail(String email) {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegExp.hasMatch(email);
  }

  bool isStrongPassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  String _getClientIp(Request request) {
    return request.headers['x-forwarded-for'] ?? 
           request.headers['x-real-ip'] ?? 
           'unknown';
  }

  bool _isRateLimited(String clientIp) {
    final rateLimit = _rateLimits[clientIp];
    if (rateLimit == null) return false;
    
    if (DateTime.now().difference(rateLimit.startTime) > _resetDuration) {
      _rateLimits.remove(clientIp);
      return false;
    }
    
    return rateLimit.attempts >= _maxAttempts;
  }

  void _incrementAttempts(String clientIp) {
    if (!_rateLimits.containsKey(clientIp)) {
      _rateLimits[clientIp] = _RateLimit(DateTime.now());
    }
    _rateLimits[clientIp]!.attempts++;
  }

  int _getResetTimeInMinutes(String clientIp) {
    final rateLimit = _rateLimits[clientIp];
    if (rateLimit == null) return 0;
    
    final timePassed = DateTime.now().difference(rateLimit.startTime);
    final remainingTime = _resetDuration - timePassed;
    return (remainingTime.inSeconds / 60).ceil();
  }
}

class _RateLimit {
  final DateTime startTime;
  int attempts;

  _RateLimit(this.startTime, {this.attempts = 1});
}
