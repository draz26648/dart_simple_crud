import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../core/interfaces/i_auth_service.dart';
import '../core/interfaces/i_user_service.dart';
import '../models/user.dart';

class AuthService implements IAuthService {
  final IUserService _userService;
  final String _jwtSecret = 'your-secret-key'; // In production, use environment variables
  final Map<String, String> _sessions = {};

  AuthService(this._userService);

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  String _generateToken(int userId) {
    final jwt = JWT(
      {
        'id': userId,
        'iat': DateTime.now().millisecondsSinceEpoch,
      },
    );

    return jwt.sign(SecretKey(_jwtSecret));
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final hashedPassword = _hashPassword(password);
      final user = await _userService.getUserByEmail(email);

      if (user == null || user.password != hashedPassword) {
        throw Exception('Invalid email or password');
      }

      if (user.id == null) {
        throw Exception('User ID is required');
      }

      final token = _generateToken(user.id!);
      _sessions[token] = user.id.toString();

      return {
        'token': token,
        'user': user.toResponseJson(),
      };
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password, {
    String? gender,
    int? age,
    String? mobileNumber,
    String? profileImagePath,
  }) async {
    try {
      // Check if user already exists
      final existingUser = await _userService.getUserByEmail(email);
      if (existingUser != null) {
        throw Exception('User with this email already exists');
      }

      final hashedPassword = _hashPassword(password);
      
      // Create new user with additional fields
      final user = User(
        name: name,
        email: email,
        password: hashedPassword,
        gender: gender,
        age: age,
        mobileNumber: mobileNumber,
        profileImagePath: profileImagePath,
      );

      final createdUser = await _userService.createUser(user);
      if (createdUser.id == null) {
        throw Exception('User ID is required');
      }

      final token = _generateToken(createdUser.id!);
      _sessions[token] = createdUser.id.toString();

      return {
        'token': token,
        'user': createdUser.toResponseJson(),
      };
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<bool> verifyToken(String token) async {
    try {
      JWT.verify(token, SecretKey(_jwtSecret));
      return _sessions.containsKey(token);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> logout(String token) async {
    _sessions.remove(token);
  }
}
