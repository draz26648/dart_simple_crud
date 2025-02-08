import 'package:postgres/postgres.dart';
import 'package:simple_crud_app/config/database_config.dart';

class CreateUsersTable {
  Future<void> up() async {
    print('Attempting to connect to database:');
    print('Host: ${DatabaseConfig.host}');
    print('Port: ${DatabaseConfig.port}');
    print('Database: ${DatabaseConfig.database}');
    print('Username: ${DatabaseConfig.username}');
    print('Connection String: ${DatabaseConfig.connectionString}');
    
    final connection = PostgreSQLConnection(
      DatabaseConfig.host,
      DatabaseConfig.port,
      DatabaseConfig.database,
      username: DatabaseConfig.username,
      password: DatabaseConfig.password
    );

    try {
      print('Opening connection...');
      await connection.open();
      print('Connection opened successfully!');

      // Create users table
      print('Creating users table...');
      await connection.query('''
        CREATE TABLE IF NOT EXISTS users (
          id SERIAL PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          gender VARCHAR(50),
          age INTEGER,
          email VARCHAR(255) NOT NULL UNIQUE,
          mobile_number VARCHAR(20),
          profile_image_path VARCHAR(255),
          password VARCHAR(255) NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');
      print('Users table created successfully!');

      // Create update_updated_at_column function
      print('Creating update_updated_at_column function...');
      await connection.query('''
        CREATE OR REPLACE FUNCTION update_updated_at_column()
        RETURNS TRIGGER AS \$\$
        BEGIN
            NEW.updated_at = CURRENT_TIMESTAMP;
            RETURN NEW;
        END;
        \$\$ language 'plpgsql'
      ''');
      print('update_updated_at_column function created successfully!');

      // Drop existing trigger if exists
      print('Dropping existing trigger if exists...');
      await connection.query('''
        DROP TRIGGER IF EXISTS update_users_updated_at ON users
      ''');
      print('Existing trigger dropped successfully!');

      // Create trigger for updating updated_at column
      print('Creating trigger for updating updated_at column...');
      await connection.query('''
        CREATE TRIGGER update_users_updated_at
        BEFORE UPDATE ON users
        FOR EACH ROW
        EXECUTE FUNCTION update_updated_at_column()
      ''');
      print('Trigger for updating updated_at column created successfully!');
    } catch (e) {
      print('Error during migration: $e');
      rethrow;
    } finally {
      print('Closing connection...');
      await connection.close();
      print('Connection closed successfully!');
    }
  }

  Future<void> down() async {
    final connection = PostgreSQLConnection(
      DatabaseConfig.host,
      DatabaseConfig.port,
      DatabaseConfig.database,
      username: DatabaseConfig.username,
      password: DatabaseConfig.password
    );

    await connection.open();

    try {
      await connection.query('DROP TABLE IF EXISTS users');
    } finally {
      await connection.close();
    }
  }
}
