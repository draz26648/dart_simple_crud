import 'dart:io';

class DatabaseConfig {
  static bool get isProduction => 
      Platform.environment['RAILWAY_ENVIRONMENT'] != null || 
      Platform.environment['DATABASE_URL'] != null;

  // Get database URL from environment or use local fallback
  static String get _databaseUrl {
    // Use Railway's DATABASE_URL if available
    if (Platform.environment['DATABASE_URL'] != null) {
      return Platform.environment['DATABASE_URL']!;
    }
    
    // For local development, encode special characters in password
    const localPassword = 'draz@123';
    final encodedPassword = Uri.encodeComponent(localPassword);
    return 'postgres://postgres:$encodedPassword@localhost:5432/dart_test_backend?sslmode=disable';
  }

  static Uri get _parsedUrl => Uri.parse(_databaseUrl);

  // Database configuration getters
  static String get host => _parsedUrl.host;
  static int get port => _parsedUrl.port;
  static String get database => _parsedUrl.path.replaceAll('/', '').split('?').first;
  static String get username => _parsedUrl.userInfo.split(':')[0];
  static String get password {
    final userInfo = _parsedUrl.userInfo.split(':');
    if (userInfo.length > 1) {
      return Uri.decodeComponent(userInfo[1]);
    }
    throw FormatException('Invalid database URL: missing password');
  }

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
