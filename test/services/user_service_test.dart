import 'package:test/test.dart';
import 'package:simple_crud_app/models/user.dart';
import 'package:simple_crud_app/core/interfaces/i_user_service.dart';
import 'package:simple_crud_app/services/user_service.dart';
import 'package:simple_crud_app/core/interfaces/i_user_repository.dart';
import 'package:simple_crud_app/core/interfaces/i_file_service.dart';

class MockUserRepository implements IUserRepository {
  final List<User> _users = [];
  int _nextId = 1;

  @override
  Future<List<User>> getAllUsers() async => _users;

  @override
  Future<User?> getUserById(int id) async {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User?> getUserByEmail(String email) async {
    try {
      return _users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User> createUser(User user) async {
    final newUser = User(
      id: _nextId++,
      email: user.email,
      name: user.name,
      password: user.password,
      profileImagePath: user.profileImagePath,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _users.add(newUser);
    return newUser;
  }

  @override
  Future<User?> updateUser(int id, User user) async {
    final index = _users.indexWhere((u) => u.id == id);
    if (index == -1) return null;
    
    final existingUser = _users[index];
    final updatedUser = existingUser.copyWith(
      email: user.email,
      name: user.name,
      password: user.password,
      profileImagePath: user.profileImagePath,
      updatedAt: DateTime.now(),
    );
    _users[index] = updatedUser;
    return updatedUser;
  }

  @override
  Future<User?> updateProfileImage(int id, String filePath) async {
    final index = _users.indexWhere((user) => user.id == id);
    if (index == -1) return null;
    
    final user = _users[index];
    final updatedUser = user.copyWith(
      profileImagePath: filePath,
      updatedAt: DateTime.now(),
    );
    _users[index] = updatedUser;
    return updatedUser;
  }

  @override
  Future<bool> deleteUser(int id) async {
    final index = _users.indexWhere((user) => user.id == id);
    if (index == -1) return false;
    _users.removeAt(index);
    return true;
  }
}

class MockFileService implements IFileService {
  @override
  Future<void> initialize() async {
    // No initialization needed for mock
  }

  @override
  bool isValidImageFile(String fileName) {
    return fileName.toLowerCase().endsWith('.jpg') || 
           fileName.toLowerCase().endsWith('.jpeg') || 
           fileName.toLowerCase().endsWith('.png') || 
           fileName.toLowerCase().endsWith('.gif');
  }

  @override
  String generateUniqueFileName(String originalFileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = originalFileName.split('.').last;
    return 'mock_$timestamp.$extension';
  }

  @override
  Future<String?> saveProfileImage(String fileName, List<int> fileBytes) async {
    return 'mock/path/to/$fileName';
  }

  @override
  Future<bool> deleteProfileImage(String? filePath) async {
    return true;
  }

  @override
  Future<String> saveFile(String sourcePath) async {
    return 'mock/path/to/file.jpg';
  }

  @override
  Future<bool> deleteFile(String filePath) async {
    return true;
  }
}

void main() {
  late IUserService userService;
  late MockUserRepository mockRepository;
  late MockFileService mockFileService;

  setUp(() {
    mockRepository = MockUserRepository();
    mockFileService = MockFileService();
    userService = UserService(mockRepository, mockFileService);
  });

  group('UserService', () {
    test('createUser should return a user with an ID', () async {
      final user = User(
        id: 0,
        email: 'test@example.com',
        name: 'Test User',
        password: 'password123',
        profileImagePath: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdUser = await userService.createUser(user);

      expect(createdUser.id, isNotNull);
      expect(createdUser.id, equals(1));
      expect(createdUser.email, equals(user.email));
      expect(createdUser.name, equals(user.name));
    });

    test('getUserById should return null for non-existent user', () async {
      final user = await userService.getUserById(999);
      expect(user, isNull);
    });

    test('getAllUsers should return empty list initially', () async {
      final users = await userService.getAllUsers();
      expect(users, isEmpty);
    });

    test('getAllUsers should return list of created users', () async {
      final user1 = User(
        id: 0,
        email: 'test1@example.com',
        name: 'Test User 1',
        password: 'password123',
        profileImagePath: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final user2 = User(
        id: 0,
        email: 'test2@example.com',
        name: 'Test User 2',
        password: 'password123',
        profileImagePath: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await userService.createUser(user1);
      await userService.createUser(user2);

      final users = await userService.getAllUsers();
      expect(users.length, equals(2));
    });

    test('updateUser should modify existing user', () async {
      final user = User(
        id: 0,
        email: 'test@example.com',
        name: 'Test User',
        password: 'password123',
        profileImagePath: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdUser = await userService.createUser(user);
      final updatedUser = await userService.updateUser(
        createdUser.id!,
        User(
          id: createdUser.id,
          email: 'updated@example.com',
          name: 'Updated User',
          password: 'newpassword123',
          profileImagePath: null,
          createdAt: createdUser.createdAt,
          updatedAt: DateTime.now(),
        ),
      );

      expect(updatedUser?.email, equals('updated@example.com'));
      expect(updatedUser?.name, equals('Updated User'));
    });

    test('deleteUser should remove user', () async {
      final user = User(
        id: 0,
        email: 'test@example.com',
        name: 'Test User',
        password: 'password123',
        profileImagePath: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdUser = await userService.createUser(user);
      expect(createdUser.id, isNotNull);
      final result = await userService.deleteUser(createdUser.id!);
      expect(result, isTrue);

      final deletedUser = await userService.getUserById(createdUser.id!);
      expect(deletedUser, isNull);
    });
  });
}
