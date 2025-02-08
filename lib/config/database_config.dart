import 'dart:io';

class DatabaseConfig {
  // Check if running in production (Railway)
  static bool get isProduction => 
      Platform.environment['RAILWAY_ENVIRONMENT']?.isNotEmpty == true ||
      Platform.environment['DATABASE_URL']?.contains('railway.app') == true;

  // Get database URL from environment or use local fallback
  static String get _databaseUrl {
    final railwayUrl = Platform.environment['DATABASE_URL'];
    if (railwayUrl?.isNotEmpty == true) {
      print('Using Railway DATABASE_URL');
      return railwayUrl!;
    }
    
    print('Using local database configuration');
    const localPassword = 'draz@123';
    final encodedPassword = Uri.encodeComponent(localPassword);
    return 'postgres://postgres:$encodedPassword@localhost:5432/dart_test_backend?sslmode=disable';
  }

  static Uri get _parsedUrl {
    try {
      return Uri.parse(_databaseUrl);
    } catch (e) {
      print('Error parsing DATABASE_URL: $e');
      print('DATABASE_URL (masked): ${_databaseUrl.replaceAll(RegExp(r':[^:@]+@'), ':***@')}');
      rethrow;
    }
  }

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
    print('Environment Variables:');
    print('  RAILWAY_ENVIRONMENT: ${Platform.environment['RAILWAY_ENVIRONMENT']}');
    print('  DATABASE_URL exists: ${Platform.environment['DATABASE_URL'] != null}');
    print('Configuration:');
    print('  Host: $host');
    print('  Port: $port');
    print('  Database: $database');
    print('  Username: $username');
    print('  Connection String (masked): ${_databaseUrl.replaceAll(RegExp(r':[^:@]+@'), ':***@')}');
  }
}
