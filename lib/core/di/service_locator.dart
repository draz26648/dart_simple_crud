import 'package:get_it/get_it.dart';
import 'package:postgres/postgres.dart';
import '../../services/database_service.dart';
import '../../services/user_service.dart';
import '../../services/file_service.dart';
import '../../services/auth_service.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../repositories/user_repository.dart';
import '../../routes/api_routes.dart';
import '../interfaces/i_user_repository.dart';
import '../interfaces/i_user_service.dart';
import '../interfaces/i_file_service.dart';
import '../interfaces/i_auth_service.dart';

final serviceLocator = GetIt.instance;

Future<void> setupDependencies() async {
  // Services
  final databaseService = await DatabaseService.getInstance();
  serviceLocator.registerSingleton<DatabaseService>(databaseService);
  serviceLocator.registerSingleton<PostgreSQLConnection>(databaseService.connection);
  
  final fileService = FileService();
  await fileService.initialize();
  serviceLocator.registerSingleton<IFileService>(fileService);

  // Repositories
  serviceLocator.registerSingleton<IUserRepository>(
    UserRepository(serviceLocator<PostgreSQLConnection>()),
  );

  // Services
  serviceLocator.registerSingleton<IUserService>(
    UserService(
      serviceLocator<IUserRepository>(),
      serviceLocator<IFileService>(),
    ),
  );

  serviceLocator.registerSingleton<IAuthService>(
    AuthService(serviceLocator<IUserService>()),
  );

  // Controllers
  serviceLocator.registerSingleton(
    UserController(serviceLocator<IUserService>()),
  );

  serviceLocator.registerSingleton(
    AuthController(
      serviceLocator<IAuthService>(),
      serviceLocator<IFileService>(),
    ),
  );

  // Routes
  serviceLocator.registerSingleton(
    ApiRoutes(
      serviceLocator<UserController>(),
      serviceLocator<AuthController>(),
      serviceLocator<IAuthService>(),
    ),
  );
}
