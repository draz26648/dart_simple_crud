import 'package:postgres/postgres.dart';
import '../config/database_config.dart';

class DatabaseService {
  late final PostgreSQLConnection _connection;
  static DatabaseService? _instance;

  DatabaseService._();

  static Future<DatabaseService> getInstance() async {
    if (_instance == null) {
      _instance = DatabaseService._();
      await _instance!._initialize();
    }
    return _instance!;
  }

  Future<void> _initialize() async {
    _connection = PostgreSQLConnection(
      DatabaseConfig.host,
      DatabaseConfig.port,
      DatabaseConfig.database,
      username: DatabaseConfig.username,
      password: DatabaseConfig.password,
    );
    await _connection.open();
  }

  Future<void> close() async {
    await _connection.close();
  }

  PostgreSQLConnection get connection => _connection;
}
