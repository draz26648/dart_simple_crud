import 'package:shelf/shelf.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_router/shelf_router.dart';
import '../controllers/user_controller.dart';
import '../controllers/auth_controller.dart';
import '../core/interfaces/i_auth_service.dart';
import '../core/interfaces/i_user_service.dart';
import '../core/interfaces/i_file_service.dart';
import '../middlewares/auth_middleware.dart';
import '../middlewares/user_middleware.dart';
import '../middlewares/file_middleware.dart';
import 'dart:convert';

class ApiRoutes {
  final UserController _userController;
  final AuthController _authController;
  final IAuthService _authService;
  final IUserService _userService;
  final IFileService _fileService;

  late final AuthMiddleware _authMiddleware;
  late final UserMiddleware _userMiddleware;
  late final FileMiddleware _fileMiddleware;

  ApiRoutes(
    this._userController,
    this._authController,
    this._authService,
    this._userService,
    this._fileService,
  ) {
    _authMiddleware = AuthMiddleware(_authService);
    _userMiddleware = UserMiddleware(_userService);
    _fileMiddleware = FileMiddleware(_fileService);
  }

  Handler get router {
    final router = Router();

    // Create a pipeline with error handling middleware
    final pipeline = Pipeline().addMiddleware(
      (Handler innerHandler) => (Request request) async {
        try {
          final response = await innerHandler(request);
          return response;
        } catch (e, stackTrace) {
          print('Unhandled error: $e\n$stackTrace');
          return Response.internalServerError(
            body: json.encode({
              'error': 'An unexpected error occurred',
            }),
            headers: {'content-type': 'application/json'},
          );
        }
      },
    );

    // Apply the pipeline to the router
    final handler = pipeline.addHandler(router.call);

    // Auth routes (no authentication required)
    router.mount('/auth', Pipeline()
      .addMiddleware(_authMiddleware.validateLoginData())
      .addMiddleware(_authMiddleware.validateRegistrationData())
      .addHandler(_authController.router.call));

    // Protected user routes
    router.mount('/users', Pipeline()
      .addMiddleware(_userMiddleware.checkUserPermissions())
      .addMiddleware(_userMiddleware.validateUserData())
      .addMiddleware(_userMiddleware.checkUserExists())
      .addHandler(_userController.router.call));

    // File upload routes with enhanced security
    router.mount('/uploads', Pipeline()
      .addMiddleware(_userMiddleware.checkUserPermissions())
      .addMiddleware(_fileMiddleware.validateFileUpload())
      .addMiddleware(_fileMiddleware.validateFileType())
      .addMiddleware(_fileMiddleware.sanitizeFileName())
      .addHandler(_userController.router.call));

    // Serve static files (for profile images) with security headers
    final staticHandler = createStaticHandler(
      'uploads',
      defaultDocument: 'index.html',
      listDirectories: false,
    );

    router.mount('/static', Pipeline()
      .addMiddleware((Handler innerHandler) {
        return (Request request) async {
          final response = await innerHandler(request);
          return response.change(headers: {
            ...response.headers,
            'X-Content-Type-Options': 'nosniff',
            'X-Frame-Options': 'DENY',
            'X-XSS-Protection': '1; mode=block',
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            'Pragma': 'no-cache',
            'Expires': '0',
          });
        };
      })
      .addHandler(staticHandler));

    return handler;
  }
}
