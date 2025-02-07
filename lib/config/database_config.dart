class DatabaseConfig {
  static const String host = 'localhost';
  static const int port = 5432;
  static const String database = 'dart_test_backend';
  static const String username = 'postgres';
  static const String password = 'draz@123';

  static String get connectionString =>
      'postgres://$username:$password@$host:$port/$database';
}
