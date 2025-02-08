import 'package:postgres/postgres.dart';
import 'package:simple_crud_app/config/database_config.dart';

class CreateUsersTable {
  Future<void> up() async {
    final connection = PostgreSQLConnection(
      DatabaseConfig.host,
      DatabaseConfig.port,
      DatabaseConfig.database,
      username: DatabaseConfig.username,
      password: DatabaseConfig.password
    );

    await connection.open();

    try {
      // Create users table
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

      // Create update_updated_at_column function
      await connection.query('''
        CREATE OR REPLACE FUNCTION update_updated_at_column()
        RETURNS TRIGGER AS \$\$
        BEGIN
            NEW.updated_at = CURRENT_TIMESTAMP;
            RETURN NEW;
        END;
        \$\$ language 'plpgsql'
      ''');

      // Drop existing trigger if exists
      await connection.query('''
        DROP TRIGGER IF EXISTS update_users_updated_at ON users
      ''');

      // Create trigger for updating updated_at column
      await connection.query('''
        CREATE TRIGGER update_users_updated_at
        BEFORE UPDATE ON users
        FOR EACH ROW
        EXECUTE FUNCTION update_updated_at_column()
      ''');
    } catch (e) {
      print('Error during migration: $e');
      rethrow;
    } finally {
      await connection.close();
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
