import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../controllers/auth_controller.dart';
import '../core/interfaces/i_auth_service.dart';
import '../middlewares/auth_middleware.dart';

class AuthRoutes {
  final AuthController _authController;
  final AuthMiddleware _authMiddleware;

  AuthRoutes(this._authController, IAuthService authService)
      : _authMiddleware = AuthMiddleware(authService);

  Router get router {
    final router = Router();

    // Login route with login validation
    router.post('/login', Pipeline()
        .addMiddleware(_authMiddleware.validateLoginData())
        .addHandler(_authController.router.call));

    // Registration route with registration validation
    router.post('/register', Pipeline()
        .addMiddleware(_authMiddleware.validateRegistrationData())
        .addHandler(_authController.router.call));

    return router;
  }
}
