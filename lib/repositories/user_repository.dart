import 'package:postgres/postgres.dart';
import '../models/user.dart';
import '../core/interfaces/i_user_repository.dart';

class UserRepository implements IUserRepository {
  final PostgreSQLConnection _connection;

  UserRepository(this._connection);

  @override
  Future<List<User>> getAllUsers() async {
    final result = await _connection.query(
      'SELECT * FROM users ORDER BY created_at DESC',
    );
    return result.map((row) => User.fromJson(row.toColumnMap())).toList();
  }

  @override
  Future<User?> getUserById(int id) async {
    final result = await _connection.query(
      'SELECT * FROM users WHERE id = @id',
      substitutionValues: {'id': id},
    );
    
    if (result.isEmpty) return null;
    return User.fromJson(result.first.toColumnMap());
  }

  @override
  Future<User?> getUserByEmail(String email) async {
    final result = await _connection.query(
      'SELECT * FROM users WHERE email = @email',
      substitutionValues: {'email': email},
    );
    
    if (result.isEmpty) return null;
    return User.fromJson(result.first.toColumnMap());
  }

  @override
  Future<User> createUser(User user) async {
    final result = await _connection.query(
      'INSERT INTO users (name, gender, age, email, mobile_number, profile_image_path, password) VALUES (@name, @gender, @age, @email, @mobile_number, @profile_image_path, @password) RETURNING *',
      substitutionValues: {
        'name': user.name,
        'gender': user.gender,
        'age': user.age,
        'email': user.email,
        'mobile_number': user.mobileNumber,
        'profile_image_path': user.profileImagePath,
        'password': user.password,
      },
    );

    return User.fromJson(result.first.toColumnMap());
  }

  @override
  Future<User> updateUser(int id, User user) async {
    final result = await _connection.query(
      'UPDATE users SET name = @name, gender = @gender, age = @age, email = @email, mobile_number = @mobile_number, profile_image_path = @profile_image_path, password = @password, updated_at = CURRENT_TIMESTAMP WHERE id = @id RETURNING *',
      substitutionValues: {
        'id': id,
        'name': user.name,
        'gender': user.gender,
        'age': user.age,
        'email': user.email,
        'mobile_number': user.mobileNumber,
        'profile_image_path': user.profileImagePath,
        'password': user.password,
      },
    );

    return User.fromJson(result.first.toColumnMap());
  }

  @override
  Future<bool> deleteUser(int id) async {
    final result = await _connection.query(
      'DELETE FROM users WHERE id = @id',
      substitutionValues: {'id': id},
    );
    return result.isNotEmpty;
  }

  @override
  Future<User?> updateProfileImage(int id, String filePath) async {
    final result = await _connection.query(
      'UPDATE users SET profile_image_path = @filePath WHERE id = @id RETURNING *',
      substitutionValues: {
        'id': id,
        'filePath': filePath,
      },
    );
    
    if (result.isEmpty) return null;
    return User.fromJson(result.first.toColumnMap());
  }
}
