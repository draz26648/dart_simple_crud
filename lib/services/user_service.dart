import '../core/interfaces/i_user_repository.dart';
import '../core/interfaces/i_file_service.dart';
import '../core/interfaces/i_user_service.dart';
import '../models/user.dart';

class UserService implements IUserService {
  final IUserRepository _userRepository;
  final IFileService _fileService;

  UserService(this._userRepository, this._fileService);

  @override
  Future<List<User>> getAllUsers() async {
    return await _userRepository.getAllUsers();
  }

  @override
  Future<User?> getUserById(int id) async {
    return await _userRepository.getUserById(id);
  }

  @override
  Future<User?> getUserByEmail(String email) async {
    return await _userRepository.getUserByEmail(email);
  }

  @override
  Future<User> createUser(User user) async {
    return await _userRepository.createUser(user);
  }

  @override
  Future<User> updateUser(int id, User user) async {
    final updatedUser = await _userRepository.updateUser(id, user);
    if (updatedUser == null) {
      throw Exception('User not found');
    }
    return updatedUser;
  }

  @override
  Future<bool> deleteUser(int id) async {
    final user = await _userRepository.getUserById(id);
    if (user == null) return false;

    // Delete profile image if exists
    if (user.profileImagePath != null) {
      await _fileService.deleteProfileImage(user.profileImagePath);
    }

    return await _userRepository.deleteUser(id);
  }

  @override
  Future<User?> updateProfileImage(int id, String filePath) async {
    final user = await _userRepository.getUserById(id);
    if (user == null) return null;

    // Delete old profile image if exists
    if (user.profileImagePath != null) {
      await _fileService.deleteProfileImage(user.profileImagePath);
    }

    return await _userRepository.updateProfileImage(id, filePath);
  }
}
