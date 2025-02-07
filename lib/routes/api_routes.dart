import 'package:shelf/shelf.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_router/shelf_router.dart';
import '../controllers/user_controller.dart';
import '../controllers/auth_controller.dart';
import '../core/interfaces/i_auth_service.dart';
import '../core/interfaces/i_user_service.dart';
import '../core/interfaces/i_file_service.dart';
import 'auth_routes.dart';
import 'user_routes.dart';
import 'file_routes.dart';
import 'dart:convert';

class ApiRoutes {
  final UserController _userController;
  final AuthController _authController;
  final IAuthService _authService;
  final IUserService _userService;
  final IFileService _fileService;

  late final AuthRoutes _authRoutes;
  late final UserRoutes _userRoutes;
  late final FileRoutes _fileRoutes;

  ApiRoutes(
    this._userController,
    this._authController,
    this._authService,
    this._userService,
    this._fileService,
  ) {
    _authRoutes = AuthRoutes(_authController, _authService);
    _userRoutes = UserRoutes(_userController, _userService);
    _fileRoutes = FileRoutes(_userController, _fileService, _userService);
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

    // Mount all routes
    router.mount('/auth', _authRoutes.router);
    router.mount('/users', _userRoutes.router);
    router.mount('/uploads', _fileRoutes.router);

    // Serve static files (for profile images) with security headers
    final staticHandler = createStaticHandler(
      'uploads',
      defaultDocument: 'index.html',
      listDirectories: false,
      serveFilesOutsidePath: false,
    );

    router.mount('/static', Pipeline()
      .addMiddleware((Handler innerHandler) {
        return (Request request) async {
          // Allow GET requests only
          if (request.method != 'GET') {
            return Response.forbidden(
              json.encode({'error': 'Method not allowed'}),
              headers: {'content-type': 'application/json'},
            );
          }

          final response = await innerHandler(request);
          return response.change(headers: {
            ...response.headers,
            'Content-Type': _getContentType(request.url.pathSegments.last),
            'X-Content-Type-Options': 'nosniff',
            'X-Frame-Options': 'DENY',
            'X-XSS-Protection': '1; mode=block',
            'Cache-Control': 'public, max-age=31536000',
            'Access-Control-Allow-Origin': '*',
          });
        };
      })
      .addHandler(staticHandler));

    return handler;
  }

  String _getContentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }
}
