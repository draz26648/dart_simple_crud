import 'package:postgres/postgres.dart';
import '../models/user.dart';
import '../core/interfaces/i_user_repository.dart';
import '../services/database_service.dart';

class UserRepository implements IUserRepository {
  final PostgreSQLConnection _connection;

  UserRepository(this._connection);

  @override
  Future<List<User>> getAllUsers() async {
    final results = await _connection.query(
      'SELECT * FROM users',
    );
    
    return results.map((row) => User(
      id: row[0] as int,
      name: row[1] as String,
      gender: row[2] as String,
      age: row[3] as int,
      email: row[4] as String,
      mobileNumber: row[5] as String,
    )).toList();
  }

  @override
  Future<User?> getUserById(int id) async {
    final results = await _connection.query(
      'SELECT * FROM users WHERE id = @id',
      substitutionValues: {'id': id},
    );
    
    if (results.isEmpty) return null;
    
    final row = results.first;
    return User(
      id: row[0] as int,
      name: row[1] as String,
      gender: row[2] as String,
      age: row[3] as int,
      email: row[4] as String,
      mobileNumber: row[5] as String,
    );
  }

  @override
  Future<User> createUser(User user) async {
    final results = await _connection.query(
      '''
      INSERT INTO users (name, gender, age, email, mobile_number)
      VALUES (@name, @gender, @age, @email, @mobileNumber)
      RETURNING *
      ''',
      substitutionValues: {
        'name': user.name,
        'gender': user.gender,
        'age': user.age,
        'email': user.email,
        'mobileNumber': user.mobileNumber,
      },
    );
    
    final row = results.first;
    return User(
      id: row[0] as int,
      name: row[1] as String,
      gender: row[2] as String,
      age: row[3] as int,
      email: row[4] as String,
      mobileNumber: row[5] as String,
    );
  }

  @override
  Future<User?> updateUser(int id, User user) async {
    final results = await _connection.query(
      '''
      UPDATE users 
      SET name = @name, gender = @gender, age = @age, 
          email = @email, mobile_number = @mobileNumber
      WHERE id = @id
      RETURNING *
      ''',
      substitutionValues: {
        'id': id,
        'name': user.name,
        'gender': user.gender,
        'age': user.age,
        'email': user.email,
        'mobileNumber': user.mobileNumber,
      },
    );
    
    if (results.isEmpty) return null;
    
    final row = results.first;
    return User(
      id: row[0] as int,
      name: row[1] as String,
      gender: row[2] as String,
      age: row[3] as int,
      email: row[4] as String,
      mobileNumber: row[5] as String,
    );
  }

  @override
  Future<bool> deleteUser(int id) async {
    final results = await _connection.query(
      'DELETE FROM users WHERE id = @id RETURNING id',
      substitutionValues: {'id': id},
    );
    return results.isNotEmpty;
  }
}
