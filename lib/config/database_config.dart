import 'dart:io';

class DatabaseConfig {
  // Always try to use Railway's DATABASE_URL first
  static String get _databaseUrl {
    final railwayUrl = Platform.environment['DATABASE_URL'];
    if (railwayUrl != null && railwayUrl.isNotEmpty) {
      print('Using Railway DATABASE_URL');
      return railwayUrl;
    }
    
    print('Using local database configuration');
    return 'postgres://postgres:${Uri.encodeComponent("draz@123")}@localhost:5432/dart_test_backend?sslmode=disable';
  }

  static Uri? _cachedUri;
  
  static Uri get _parsedUrl {
    if (_cachedUri != null) return _cachedUri!;
    
    try {
      final url = _databaseUrl;
      print('Parsing DATABASE_URL (masked): ${url.replaceAll(RegExp(r':[^:@]+@'), ':***@')}');
      _cachedUri = Uri.parse(url);
      return _cachedUri!;
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

  // Check if running in production environment
  static bool get isProduction => Platform.environment['DATABASE_URL'] != null;

  // Print configuration for debugging
  static void printConfig() {
    print('\n=== Database Configuration ===');
    print('Environment Variables:');
    print('  DATABASE_URL exists: ${Platform.environment['DATABASE_URL'] != null}');
    print('  Using Railway: ${Platform.environment['DATABASE_URL'] != null}');
    
    print('\nConnection Details:');
    print('  Host: $host');
    print('  Port: $port');
    print('  Database: $database');
    print('  Username: $username');
    print('  Connection String (masked): ${_databaseUrl.replaceAll(RegExp(r':[^:@]+@'), ':***@')}');
  }
}
