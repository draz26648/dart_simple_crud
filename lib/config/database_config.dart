import 'dart:io';

class DatabaseConfig {
  static bool get isProduction => 
      Platform.environment['RAILWAY_ENVIRONMENT'] != null || 
      Platform.environment['DATABASE_URL'] != null;

  // Get database URL from environment or use local fallback
  static String get _databaseUrl => 
      Platform.environment['DATABASE_URL'] ?? 
      'postgres://postgres:draz@123@localhost:5432/dart_test_backend?sslmode=disable';

  static Uri get _parsedUrl => Uri.parse(_databaseUrl);

  // Database configuration getters
  static String get host => _parsedUrl.host;
  static int get port => _parsedUrl.port;
  static String get database => _parsedUrl.path.replaceAll('/', '').split('?').first;
  static String get username => _parsedUrl.userInfo.split(':')[0];
  static String get password => Uri.decodeComponent(_parsedUrl.userInfo.split(':')[1]);

  // Full connection string
  static String get connectionString => _databaseUrl;

  // Print configuration for debugging
  static void printConfig() {
    print('Database Configuration:');
    print('Is Production: $isProduction');
    print('Host: $host');
    print('Port: $port');
    print('Database: $database');
    print('Username: $username');
    print('Connection String (masked): ${_databaseUrl.replaceAll(RegExp(r':[^:@]+@'), ':***@')}');
  }
}
