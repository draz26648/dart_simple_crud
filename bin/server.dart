import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:simple_crud_app/core/di/service_locator.dart';
import 'package:simple_crud_app/config/server_config.dart';
import 'package:simple_crud_app/database/migrations/001_create_users_table.dart';
import 'package:simple_crud_app/routes/api_routes.dart';
import 'package:simple_crud_app/controllers/user_controller.dart';
import 'package:simple_crud_app/controllers/auth_controller.dart';
import 'package:simple_crud_app/core/interfaces/i_auth_service.dart';
import 'package:simple_crud_app/core/interfaces/i_user_service.dart';
import 'package:simple_crud_app/core/interfaces/i_file_service.dart';
import 'package:simple_crud_app/config/database_config.dart';
import 'package:dotenv/dotenv.dart';

void main() async {
  try {
    print('\n=== Environment Information ===');
    print('RAILWAY_ENVIRONMENT: ${Platform.environment['RAILWAY_ENVIRONMENT']}');
    var env = DotEnv(includePlatformEnvironment: true)..load();
    print('DATABASE_URL: ${env['DATABASE_URL']?.replaceAll(RegExp(r':[^:@]+@'), ':***@')}');
    print('PORT: ${Platform.environment['PORT']}');
    print('PWD: ${Platform.environment['PWD']}');
    
    print('\n=== Database Configuration ===');
    DatabaseConfig.printConfig();
    
    print('\n=== Starting Server ===');
    print('Starting server initialization...');
    
    // Run migrations
    print('\n=== Running Migrations ===');
    await CreateUsersTable().up();
    print('Migrations completed successfully.');
    
    // Setup dependencies
    print('\n=== Setting up Dependencies ===');
    await setupDependencies();
    print('Dependencies setup completed.');
    
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
                body: 'Internal Server Error',
                headers: ServerConfig.defaultHeaders,
              );
            }
          },
        )
        .addHandler(ApiRoutes(
          serviceLocator<UserController>(),
          serviceLocator<AuthController>(),
          serviceLocator<IAuthService>(),
          serviceLocator<IUserService>(),
          serviceLocator<IFileService>(),
        ).router);

    // Start the server
    final port = int.parse(Platform.environment['PORT'] ?? '8080');
    final ip = Platform.environment['HOST'] ?? '0.0.0.0';
    
    final server = await shelf_io.serve(handler, ip, port);
    
    print('Server running on http://${server.address.host}:${server.port}');
  } catch (e, stackTrace) {
    print('Fatal error during server startup:');
    print(e);
    print(stackTrace);
    exit(1);
  }
}
