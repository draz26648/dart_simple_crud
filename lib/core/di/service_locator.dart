import 'package:get_it/get_it.dart';
import '../../services/database_service.dart';
import '../../services/user_service.dart';
import '../../repositories/user_repository.dart';
import '../../controllers/user_controller.dart';
import '../../routes/api_routes.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> setupDependencies() async {
  // Services
  final dbService = await DatabaseService.getInstance();
  serviceLocator.registerSingleton<DatabaseService>(dbService);
  
  // Repositories
  serviceLocator.registerSingleton<UserRepository>(
    UserRepository(dbService.connection),
  );
  
  // Services
  serviceLocator.registerSingleton<UserService>(
    UserService(serviceLocator<UserRepository>()),
  );
  
  // Controllers
  serviceLocator.registerSingleton<UserController>(
    UserController(serviceLocator<UserService>()),
  );
  
  // Routes
  serviceLocator.registerSingleton<ApiRoutes>(
    ApiRoutes(serviceLocator<UserController>()),
  );
}
