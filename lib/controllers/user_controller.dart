import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../core/interfaces/i_user_service.dart';
import '../models/user.dart';

class UserController {
  final IUserService _userService;
  final Router _router = Router();

  UserController(this._userService) {
    _router.get('/users', getAllUsers);
    _router.get('/users/<id>', getUserById);
    _router.post('/users', createUser);
    _router.put('/users/<id>', updateUser);
    _router.delete('/users/<id>', deleteUser);
    _router.post('/users/<id>/profile-image', uploadProfileImage);
  }

  Router get router => _router;

  Future<Response> getAllUsers(Request request) async {
    try {
      final users = await _userService.getAllUsers();
      return Response.ok(
        jsonEncode({
          'message': 'Users fetched successfully',
          'users': users.map((user) => user.toResponseJson()).toList(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Failed to get users',
          'details': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> getUserById(Request request, String id) async {
    try {
      final int userId = int.parse(id);
      final user = await _userService.getUserById(userId);
      if (user == null) {
        return Response.notFound(
          jsonEncode({
            'error': 'User not found',
            'details': 'No user found with ID: $id',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode(user.toResponseJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response(
        400,
        body: jsonEncode({
          'error': 'Failed to get user',
          'details': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> createUser(Request request) async {
    try {
      final String body = await request.readAsString();
      final Map<String, dynamic> userData;
      try {
        userData = jsonDecode(body) as Map<String, dynamic>;
      } catch (e) {
        return Response(
          400,
          body: jsonEncode({
            'error': 'Invalid JSON format',
            'details': e.toString(),
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final newUser = await _userService.createUser(User.fromJson(userData));
      return Response.ok(
        jsonEncode({
          'message': 'User created successfully',
          'user': newUser.toResponseJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response(
        400,
        body: jsonEncode({
          'error': 'Failed to create user',
          'details': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> updateUser(Request request, String id) async {
    try {
      final int userId = int.parse(id);
      final String body = await request.readAsString();
      final Map<String, dynamic> userData;
      try {
        userData = jsonDecode(body) as Map<String, dynamic>;
      } catch (e) {
        return Response(
          400,
          body: jsonEncode({
            'error': 'Invalid JSON format',
            'details': e.toString(),
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final updatedUser = await _userService.updateUser(userId, User.fromJson(userData));
      if (updatedUser == null) {
        return Response.notFound(
          jsonEncode({
            'error': 'User not found',
            'details': 'No user found with ID: $id',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'message': 'User updated successfully',
          'user': updatedUser.toResponseJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response(
        400,
        body: jsonEncode({
          'error': 'Failed to update user',
          'details': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> deleteUser(Request request, String id) async {
    try {
      final int userId = int.parse(id);
      final deleted = await _userService.deleteUser(userId);
      if (!deleted) {
        return Response.notFound(
          jsonEncode({
            'error': 'User not found',
            'details': 'No user found with ID: $id',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({'message': 'User deleted successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response(
        400,
        body: jsonEncode({
          'error': 'Failed to delete user',
          'details': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> uploadProfileImage(Request request, String id) async {
    try {
      final int userId = int.parse(id);
      final String filePath = await request.readAsString();

      final updatedUser = await _userService.updateProfileImage(userId, filePath);
      if (updatedUser == null) {
        return Response.notFound(
          jsonEncode({
            'error': 'User not found',
            'details': 'No user found with ID: $id',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'message': 'Profile image updated successfully',
          'user': updatedUser.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response(
        400,
        body: jsonEncode({
          'error': 'Failed to update profile image',
          'details': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
