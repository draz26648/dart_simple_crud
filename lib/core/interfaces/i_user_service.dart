import '../../models/user.dart';

abstract class IUserService {
  Future<List<User>> getAllUsers();
  Future<User?> getUserById(int id);
  Future<User> createUser(Map<String, dynamic> userData);
  Future<User?> updateUser(int id, Map<String, dynamic> userData);
  Future<bool> deleteUser(int id);
}
