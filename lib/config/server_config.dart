class ServerConfig {
  static const String host = 'localhost';
  static const int port = 8080;
  
  // Add more configuration as needed
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type',
  };
}
