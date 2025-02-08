import 'dart:io';

class DatabaseConfig {
  // Check if running in production (Railway)
  static bool get isProduction => 
      Platform.environment['RAILWAY_ENVIRONMENT']?.isNotEmpty == true;

  // Get database URL from environment or use local fallback
  static String get _databaseUrl {
    // First try RAILWAY_DATABASE_URL
    final railwayUrl = Platform.environment['DATABASE_URL'];
    
    if (isProduction) {
      if (railwayUrl == null || railwayUrl.isEmpty) {
        throw StateError('''
          No DATABASE_URL found in Railway environment.
          Please make sure to:
          1. Add a PostgreSQL service in Railway
          2. Link it to your project
          3. Verify DATABASE_URL is set in environment variables
        ''');
      }
      return railwayUrl;
    }
    
    // For local development
    return Platform.environment['DATABASE_URL'] ?? 
           'postgres://postgres:${Uri.encodeComponent("draz@123")}@localhost:5432/dart_test_backend?sslmode=disable';
  }

  static Uri get _parsedUrl {
    try {
      final url = _databaseUrl;
      print('Attempting to parse DATABASE_URL (masked): ${url.replaceAll(RegExp(r':[^:@]+@'), ':***@')}');
      return Uri.parse(url);
    } catch (e) {
      print('Error parsing DATABASE_URL: $e');
      rethrow;
    }
  }

  // Database configuration getters
  static String get host => _parsedUrl.host;
  static int get port => _parsedUrl.port;
  static String get database {
    final path = _parsedUrl.path.replaceAll('/', '');
    return path.contains('?') ? path.split('?')[0] : path;
  }
  
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
    print('\n=== Database Configuration ===');
    print('Environment:');
    print('  RAILWAY_ENVIRONMENT: ${Platform.environment['RAILWAY_ENVIRONMENT']}');
    print('  Is Production: $isProduction');
    print('  DATABASE_URL exists: ${Platform.environment['DATABASE_URL'] != null}');
    
    if (!isProduction) {
      print('\nConfiguration:');
      print('  Host: $host');
      print('  Port: $port');
      print('  Database: $database');
      print('  Username: $username');
    }
    
    print('\nConnection String (masked): ${_databaseUrl.replaceAll(RegExp(r':[^:@]+@'), ':***@')}');
  }
}
