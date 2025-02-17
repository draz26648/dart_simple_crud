# User Management API

A robust REST API built with Dart and Shelf framework for user management, featuring authentication, authorization, and profile management with image upload support.

## Key Features 

- Secure Authentication System
- JWT-based Authorization
- User Management
- Profile Image Upload Support
- Advanced Endpoint Protection
- Input Validation
- Rate Limiting
- PostgreSQL Database

## Prerequisites 

1. Dart SDK (2.19.0 or later)
2. PostgreSQL (14.0 or later)
3. Git

## Installation & Setup 

1. Clone the repository:
```bash
git clone https://github.com/draz26648/dart_simple_crud.git
cd root_folder
```

2. Install dependencies:
```bash
dart pub get
```

3. Database setup:
   - Create a new PostgreSQL database
   - Update `lib/config/database_config.dart` with your database credentials:
   ```dart
   class DatabaseConfig {
     static const String host = 'localhost';
     static const int port = 5432;
     static const String database = 'your_database';
     static const String username = 'your_username';
     static const String password = 'your_password';
   }
   ```

4. Create uploads directory:
```bash
mkdir uploads
```

## Running the Project 

Start the server:
```bash
dart run bin/server.dart
```
The server will run on port 8080 by default.

## API Endpoints 

### Authentication

#### Register New User
```http
POST /auth/register
Content-Type: multipart/form-data

Fields:
- name (required)
- email (required)
- password (required)
- gender (optional)
- age (optional)
- mobile_number (optional)
- profile_image (optional, file)
```

#### Login
```http
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

### User Management

#### Get All Users
```http
GET /users
Authorization: Bearer <token>
```

#### Get User by ID
```http
GET /users/{id}
Authorization: Bearer <token>
```

#### Update User
```http
PUT /users/{id}
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Updated Name",
  "gender": "male",
  "age": 30
}
```

#### Delete User
```http
DELETE /users/{id}
Authorization: Bearer <token>
```

## Security Features 

- Password hashing using bcrypt
- JWT authentication for protected endpoints
- Input validation and sanitization
- Brute force protection with rate limiting
- Secure file upload validation
- CORS configuration
- Security headers

## Project Structure 

```
lib/
├── bin/
│   └── server.dart          # Application entry point
├── lib/
│   ├── config/              # Configuration files
│   ├── controllers/         # Request handlers
│   ├── core/               
│   │   ├── di/             # Dependency injection
│   │   └── interfaces/     # Interfaces
│   ├── database/           # Database configuration
│   ├── middlewares/        # Middleware handlers
│   ├── models/             # Data models
│   ├── repositories/       # Data access layer
│   ├── routes/             # Route definitions
│   └── services/           # Business logic
└── test/                   # Tests
```

## Best Practices Implemented 

- SOLID principles
- Repository pattern
- Dependency injection
- Consistent error handling
- Code documentation
- Clean architecture
- Middleware-based request processing
- Service locator pattern

## Response Format 

### Success Response
```json
{
  "message": "Operation successful",
  "data": {
    // Response data
  }
}
```

### Error Response
```json
{
  "error": "Error message",
  "details": "Additional error details"
}
```

## Design Patterns Used

The project implements several design patterns to ensure maintainability, scalability, and clean architecture:

1. **Dependency Injection (DI) Pattern**
   - Uses `get_it` as a service locator
   - Constructor-based dependency injection throughout classes
   - Example: `UserService` receives `IUserRepository` and `IFileService` through constructor

2. **Repository Pattern**
   - Separates data access logic into dedicated repositories
   - Abstracts database operations
   - Example: `UserRepository` handles all user-related database operations

3. **Interface Segregation (SOLID Principle)**
   - Separate interfaces for different services
   - Examples: `IUserService`, `IAuthService`, `IFileService`
   - Ensures classes only depend on interfaces they use

4. **Singleton Pattern**
   - Used in `DatabaseService` to ensure single database connection
   - Services registered as singletons in `service_locator`
   - Manages shared resources efficiently

5. **Middleware Pattern**
   - Handles HTTP request processing pipeline
   - Examples: `AuthMiddleware`, `UserMiddleware`, `FileMiddleware`
   - Enables request/response transformation and validation

6. **MVC-like Pattern**
   - Models: Data structures in `models` directory
   - Controllers: Request handlers in `controllers` directory
   - Modified for API architecture without traditional views

7. **Factory Pattern**
   - Implemented through `service_locator`
   - Centralizes object creation
   - Manages dependencies and their lifecycle

8. **Service Layer Pattern**
   - Services contain business logic
   - Separates controllers from repositories
   - Promotes separation of concerns

9. **Strategy Pattern**
   - Implemented through interfaces
   - Allows runtime implementation switching
   - Enhances code flexibility and maintainability

10. **Pipeline Pattern**
    - Implements request processing through middleware chain
    - Sequential processing of requests
    - Example: Request validation, authentication, and authorization pipeline

These patterns contribute to:
- Clean separation of concerns
- Enhanced testability
- Improved scalability
- Better maintainability
- Flexible architecture

## Contributing 

We welcome contributions! Please follow these steps:
1. Fork the repository
2. Create a feature branch
3. Submit a Pull Request

## License 

This project is licensed under the [MIT License](LICENSE).

## Support 

If you encounter any issues or have questions, please open an issue in the project repository.
