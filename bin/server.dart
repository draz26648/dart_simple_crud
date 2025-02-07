import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import '../lib/core/di/service_locator.dart';
import '../lib/config/server_config.dart';
import '../lib/services/database_service.dart';
import '../lib/routes/api_routes.dart';
import '../lib/database/migrations/001_create_users_table.dart';

void main() async {
  try {
    print('Starting server initialization...');
    
    // Setup dependencies
    print('Setting up dependencies...');
    await setupDependencies();
    print('Dependencies setup completed.');
    
    // Run migrations
    print('Running database migrations...');
    final dbService = serviceLocator<DatabaseService>();
    await createUsersTable(dbService.connection);
    print('Database migrations completed.');
    
    // Create a pipeline
    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(
          (innerHandler) => (request) async {
            try {
              final response = await innerHandler(request);
              return response.change(
                headers: {
                  ...ServerConfig.defaultHeaders,
                  ...response.headers,
                },
              );
            } catch (e, stackTrace) {
              print('Error handling request: $e');
              print('Stack trace: $stackTrace');
              return Response.internalServerError(
                headers: ServerConfig.defaultHeaders,
                body: '{"error": "Internal Server Error", "details": "${e.toString()}"}',
              );
            }
          },
        )
        .addHandler(serviceLocator<ApiRoutes>().router);

    // Start server
    print('Starting server...');
    final server = await shelf_io.serve(
      handler,
      ServerConfig.host == 'localhost' ? InternetAddress.anyIPv4 : ServerConfig.host,
      ServerConfig.port,
    );

    print('Server running on http://${server.address.host}:${server.port}');
    
    // Handle shutdown
    ProcessSignal.sigint.watch().listen((signal) async {
      print('\nReceived signal to terminate. Closing connections...');
      await serviceLocator<DatabaseService>().close();
      await server.close();
      print('Server stopped.');
      exit(0);
    });
  } catch (e, stackTrace) {
    print('Fatal error during server startup:');
    print('Error: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}
