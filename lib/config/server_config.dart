import 'dart:io';

class ServerConfig {
  static String get host => Platform.environment['HOST'] ?? '0.0.0.0';
  static int get port => int.parse(Platform.environment['PORT'] ?? '8080');
  
  // Add more configuration as needed
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type',
  };
}
