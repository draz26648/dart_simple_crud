import 'dart:io';

class DatabaseConfig {
  static final bool isProduction = Platform.environment['RAILWAY_ENVIRONMENT'] != null;
  
  // Default local configuration
  static const String _localHost = 'localhost';
  static const int _localPort = 5432;
  static const String _localDatabase = 'dart_test_backend';
  static const String _localUsername = 'postgres';
  static const String _localPassword = 'draz@123';

  // Get database configuration
  static String get host => isProduction 
      ? Uri.parse(Platform.environment['DATABASE_URL']!).host 
      : _localHost;
      
  static int get port => isProduction 
      ? Uri.parse(Platform.environment['DATABASE_URL']!).port 
      : _localPort;
      
  static String get database => isProduction 
      ? Uri.parse(Platform.environment['DATABASE_URL']!).path.replaceAll('/', '') 
      : _localDatabase;
      
  static String get username => isProduction 
      ? Uri.parse(Platform.environment['DATABASE_URL']!).userInfo.split(':')[0] 
      : _localUsername;
      
  static String get password => isProduction 
      ? Uri.parse(Platform.environment['DATABASE_URL']!).userInfo.split(':')[1] 
      : _localPassword;

  // Get full connection string
  static String get connectionString => isProduction 
      ? Platform.environment['DATABASE_URL']!
      : 'postgres://$_localUsername:$_localPassword@$_localHost:$_localPort/$_localDatabase';
}
