import 'dart:io';

class DatabaseConfig {
  static final Uri _databaseUrl = Uri.parse(
    Platform.environment['DATABASE_URL'] ?? 
    'postgres://postgres:draz@123@localhost:5432/dart_test_backend'
  );

  static String get host => _databaseUrl.host;
  static int get port => _databaseUrl.port;
  static String get database => _databaseUrl.path.replaceAll('/', '');
  static String get username => _databaseUrl.userInfo.split(':')[0];
  static String get password => _databaseUrl.userInfo.split(':')[1];

  static String get connectionString => Platform.environment['DATABASE_URL'] ??
      'postgres://$username:$password@$host:$port/$database';
}
