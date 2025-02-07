import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../controllers/user_controller.dart';
import '../core/interfaces/i_user_service.dart';
import '../middlewares/user_middleware.dart';

class UserRoutes {
  final UserController _userController;
  final UserMiddleware _userMiddleware;

  UserRoutes(this._userController, IUserService userService)
      : _userMiddleware = UserMiddleware(userService);

  Router get router {
    final router = Router();

    // Apply middleware pipeline for all user routes
    final pipeline = Pipeline()
        .addMiddleware(_userMiddleware.checkUserPermissions())
        .addMiddleware((Handler innerHandler) {
          return (Request request) async {
            // Skip user existence check for GET /users (list all users)
            if (request.method == 'GET' && request.url.pathSegments.length <= 1) {
              return innerHandler(request);
            }
            
            // Apply user existence check for other endpoints
            return _userMiddleware.checkUserExists()(innerHandler)(request);
          };
        })
        .addMiddleware(_userMiddleware.validateUserData());

    // Mount the user controller with the pipeline
    router.mount('/', pipeline.addHandler(_userController.router));

    return router;
  }
}
