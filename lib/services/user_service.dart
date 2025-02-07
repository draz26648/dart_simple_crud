import '../models/user.dart';
import '../core/interfaces/i_user_repository.dart';
import '../core/interfaces/i_user_service.dart';

class UserService implements IUserService {
  final IUserRepository _userRepository;

  UserService(this._userRepository);

  @override
  Future<List<User>> getAllUsers() async {
    return _userRepository.getAllUsers();
  }

  @override
  Future<User?> getUserById(int id) async {
    return _userRepository.getUserById(id);
  }

  @override
  Future<User> createUser(Map<String, dynamic> userData) async {
    final user = User(
      name: userData['name'] as String,
      gender: userData['gender'] as String,
      age: userData['age'] as int,
      email: userData['email'] as String,
      mobileNumber: userData['mobileNumber'] as String,
    );

    return _userRepository.createUser(user);
  }

  @override
  Future<User?> updateUser(int id, Map<String, dynamic> userData) async {
    final existingUser = await getUserById(id);
    if (existingUser == null) return null;

    final user = User(
      id: id,  
      name: userData['name'] as String? ?? existingUser.name,
      gender: userData['gender'] as String? ?? existingUser.gender,
      age: userData['age'] as int? ?? existingUser.age,
      email: userData['email'] as String? ?? existingUser.email,
      mobileNumber: userData['mobileNumber'] as String? ?? existingUser.mobileNumber,
    );

    return _userRepository.updateUser(id, user);
  }

  @override
  Future<bool> deleteUser(int id) async {
    return _userRepository.deleteUser(id);
  }
}
