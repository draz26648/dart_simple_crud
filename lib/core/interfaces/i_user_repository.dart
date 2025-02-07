import '../../models/user.dart';

abstract class IUserRepository {
  Future<List<User>> getAllUsers();
  Future<User?> getUserById(int id);
  Future<User> createUser(User user);
  Future<User?> updateUser(int id, User user);
  Future<bool> deleteUser(int id);
}
