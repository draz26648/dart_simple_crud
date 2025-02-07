import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../controllers/user_controller.dart';
import '../core/interfaces/i_file_service.dart';
import '../core/interfaces/i_user_service.dart';
import '../middlewares/file_middleware.dart';
import '../middlewares/user_middleware.dart';

class FileRoutes {
  final UserController _userController;
  final FileMiddleware _fileMiddleware;
  final UserMiddleware _userMiddleware;

  FileRoutes(
    this._userController,
    IFileService fileService,
    IUserService userService,
  )   : _fileMiddleware = FileMiddleware(fileService),
        _userMiddleware = UserMiddleware(userService);

  Router get router {
    final router = Router();

    // Apply middleware pipeline for file operations
    final pipeline = Pipeline()
        .addMiddleware(_userMiddleware.checkUserPermissions())
        .addMiddleware(_fileMiddleware.validateFileUpload())
        .addMiddleware(_fileMiddleware.validateFileType())
        .addMiddleware(_fileMiddleware.sanitizeFileName());

    // Mount the file handling routes with the pipeline
    router.mount('/', pipeline.addHandler(_userController.router.call));

    return router;
  }
}
