import 'package:shelf_router/shelf_router.dart';
import '../controllers/user_controller.dart';

class ApiRoutes {
  final UserController _userController;

  ApiRoutes(this._userController);

  Router get router {
    final router = Router();

    // User routes
    router.get('/users', _userController.getAllUsers);
    router.get('/users/<id>', _userController.getUserById);
    router.post('/users', _userController.createUser);
    router.put('/users/<id>', _userController.updateUser);
    router.delete('/users/<id>', _userController.deleteUser);

    return router;
  }
}
