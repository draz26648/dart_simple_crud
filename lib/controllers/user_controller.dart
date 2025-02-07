import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../core/interfaces/i_user_service.dart';

class UserController {
  final IUserService _userService;

  UserController(this._userService);

  Future<Response> getAllUsers(Request request) async {
    try {
      final users = await _userService.getAllUsers();
      return Response.ok(
        jsonEncode({
          'message': 'Users fetched successfully',
          'users': users.map((user) => user.toJson()).toList(),
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
      final userId = int.tryParse(id);
      if (userId == null) {
        return Response(
          400,
          body: jsonEncode({'error': 'Invalid user ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final user = await _userService.getUserById(userId);
      if (user == null) {
        return Response.notFound(
          jsonEncode({'error': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode(user.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
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
      final body = await request.readAsString();
      if (body.isEmpty) {
        return Response(
          400,
          body: jsonEncode({'error': 'Request body is empty'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      Map<String, dynamic> userData;
      try {
        userData = jsonDecode(body);
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

      final newUser = await _userService.createUser(userData);
      return Response.ok(
        jsonEncode({
          'message': 'User created successfully',
          'user': newUser.toJson(),
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
      final userId = int.tryParse(id);
      if (userId == null) {
        return Response(
          400,
          body: jsonEncode({'error': 'Invalid user ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final body = await request.readAsString();
      if (body.isEmpty) {
        return Response(
          400,
          body: jsonEncode({'error': 'Request body is empty'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      Map<String, dynamic> userData;
      try {
        userData = jsonDecode(body);
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

      final updatedUser = await _userService.updateUser(userId, userData);
      if (updatedUser == null) {
        return Response.notFound(
          jsonEncode({'error': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'message': 'User updated successfully',
          'user': updatedUser.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
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
      final userId = int.tryParse(id);
      if (userId == null) {
        return Response(
          400,
          body: jsonEncode({'error': 'Invalid user ID'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final deleted = await _userService.deleteUser(userId);
      if (!deleted) {
        return Response.notFound(
          jsonEncode({'error': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'message': 'User deleted successfully',
          'userId': userId,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Failed to delete user',
          'details': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
