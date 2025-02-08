import 'dart:io';

class DatabaseConfig {
  static String get host => Platform.environment['DATABASE_HOST'] ?? 'localhost';
  static int get port => int.parse(Platform.environment['DATABASE_PORT'] ?? '5432');
  static String get database => Platform.environment['DATABASE_NAME'] ?? 'dart_test_backend';
  static String get username => Platform.environment['DATABASE_USER'] ?? 'postgres';
  static String get password => Platform.environment['DATABASE_PASSWORD'] ?? 'draz@123';

  static String get connectionString =>
      'postgres://$username:$password@$host:$port/$database';
}
