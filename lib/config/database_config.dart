import 'dart:io';

class DatabaseConfig {
  static final bool isProduction = Platform.environment['RAILWAY_ENVIRONMENT'] != null;
  
  // Default local configuration
  static const String _localHost = '127.0.0.1';  // Using IP instead of localhost
  static const int _localPort = 5432;  // Default PostgreSQL port
  static const String _localDatabase = 'dart_test_backend';
  static const String _localUsername = 'postgres';
  static const String _localPassword = 'postgres';

  static Uri? get _databaseUrl {
    final url = Platform.environment['DATABASE_URL'];
    return url != null ? Uri.parse(url) : null;
  }

  // Get database configuration
  static String get host => 
      _databaseUrl?.host ?? _localHost;
      
  static int get port => 
      _databaseUrl?.port ?? _localPort;
      
  static String get database => 
      _databaseUrl?.path.replaceAll('/', '') ?? _localDatabase;
      
  static String get username => 
      _databaseUrl?.userInfo.split(':')[0] ?? _localUsername;
      
  static String get password => 
      _databaseUrl?.userInfo.split(':')[1] ?? _localPassword;

  // Get full connection string
  static String get connectionString => 
      Platform.environment['DATABASE_URL'] ?? 
      'postgres://$username:$password@$host:$port/$database';
}
