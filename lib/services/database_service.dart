import 'package:postgres/postgres.dart';
import '../config/database_config.dart';

class DatabaseService {
  late final PostgreSQLConnection _connection;
  static DatabaseService? _instance;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 5);

  DatabaseService._();

  PostgreSQLConnection get connection => _connection;

  static Future<DatabaseService> getInstance() async {
    if (_instance == null) {
      _instance = DatabaseService._();
      await _instance!._initialize();
    }
    return _instance!;
  }

  Future<void> _initialize() async {
    int retryCount = 0;
    while (retryCount < _maxRetries) {
      try {
        _connection = PostgreSQLConnection(
          DatabaseConfig.host,
          DatabaseConfig.port,
          DatabaseConfig.database,
          username: DatabaseConfig.username,
          password: DatabaseConfig.password,
          timeoutInSeconds: 30,
          useSSL: true,
        );
        
        await _connection.open();
        print('Database connection established successfully');
        
        // Test the connection
        await _connection.query('SELECT 1');
        return;
      } catch (e) {
        retryCount++;
        print('Database connection attempt $retryCount failed: ${e.toString()}');
        
        if (retryCount >= _maxRetries) {
          throw DatabaseException(
            'Failed to connect to database after $_maxRetries attempts: ${e.toString()}',
          );
        }
        
        await Future.delayed(_retryDelay);
      }
    }
  }

  Future<void> close() async {
    try {
      await _connection.close();
      print('Database connection closed successfully');
    } catch (e) {
      print('Error closing database connection: ${e.toString()}');
      throw DatabaseException('Failed to close database connection: ${e.toString()}');
    }
  }

  Future<void> checkConnection() async {
    try {
      await _connection.query('SELECT 1');
    } catch (e) {
      print('Database connection check failed: ${e.toString()}');
      await _initialize();
    }
  }
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}
