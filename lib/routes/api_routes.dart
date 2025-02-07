import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import '../controllers/user_controller.dart';
import '../controllers/auth_controller.dart';
import '../core/interfaces/i_auth_service.dart';

class ApiRoutes {
  final UserController _userController;
  final AuthController _authController;
  final IAuthService _authService;

  ApiRoutes(this._userController, this._authController, this._authService);

  Router get router {
    final router = Router();

    // Auth routes (no authentication required)
    router.mount('/auth', _authController.router.call);

    // Protected routes (authentication required)
    router.mount('/users', Pipeline()
      .addMiddleware(_authMiddleware)
      .addHandler(_userController.router.call));

    // Serve static files (for profile images)
    final staticHandler = createStaticHandler(
      'uploads',
      defaultDocument: 'index.html',
      listDirectories: false,
    );
    router.mount('/static', Pipeline().addHandler(staticHandler));

    return router;
  }

  Middleware get _authMiddleware {
    return (Handler innerHandler) {
      return (Request request) async {
        final authHeader = request.headers['authorization'];
        if (authHeader == null || !authHeader.startsWith('Bearer ')) {
          return Response.unauthorized('No valid token provided');
        }

        final token = authHeader.substring(7);
        final isValid = await _authService.verifyToken(token);

        if (!isValid) {
          return Response.unauthorized('Invalid or expired token');
        }

        return innerHandler(request);
      };
    };
  }
}
