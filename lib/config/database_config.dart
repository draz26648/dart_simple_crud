import 'dart:io';

class DatabaseConfig {
  static final bool isProduction = Platform.environment['RAILWAY_ENVIRONMENT'] != null;
  
  // Default local configuration
  static const String _localHost = 'localhost';
  static const int _localPort = 5432;
  static const String _localDatabase = 'dart_test_backend'; 
  static const String _localUsername = 'postgres';
  static const String _localPassword = 'draz@123';

  static Uri? get _databaseUrl {
    final url = Platform.environment['DATABASE_URL'];
    if (url == null) return null;
    
    try {
      return Uri.parse(url);
    } catch (e) {
      print('Error parsing DATABASE_URL: $e');
      return null;
    }
  }

  // Get database configuration
  static String get host => 
      _databaseUrl?.host ?? _localHost;
      
  static int get port => 
      _databaseUrl?.port ?? _localPort;
      
  static String get database {
    if (_databaseUrl != null) {
      // Remove leading slash and query parameters for Railway URL
      return _databaseUrl!.path.replaceAll('/', '').split('?').first;
    }
    return _localDatabase;
  }
      
  static String get username => 
      _databaseUrl?.userInfo.split(':')[0] ?? _localUsername;
      
  static String get password {
    if (_databaseUrl != null) {
      final userInfo = _databaseUrl!.userInfo.split(':');
      if (userInfo.length > 1) {
        // Handle URL encoded characters in password
        return Uri.decodeComponent(userInfo[1]);
      }
    }
    return _localPassword;
  }

  // Get full connection string
  static String get connectionString {
    final dbUrl = Platform.environment['DATABASE_URL'];
    if (dbUrl != null && isProduction) {
      // Use Railway's DATABASE_URL directly in production
      return dbUrl;
    }
    // Use local configuration with SSL disabled for development
    return 'postgres://$username:${Uri.encodeComponent(password)}@$host:$port/$database?sslmode=disable';
  }
}
