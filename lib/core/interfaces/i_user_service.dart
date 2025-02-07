import '../../models/user.dart';

abstract class IUserService {
  Future<List<User>> getAllUsers();
  Future<User?> getUserById(int id);
  Future<User?> getUserByEmail(String email);
  Future<User> createUser(User user);
  Future<User?> updateUser(int id, User user);
  Future<bool> deleteUser(int id);
  Future<User?> updateProfileImage(int id, String filePath);
}
