import 'package:postgres/postgres.dart';
import 'package:simple_crud_app/config/database_config.dart';

class CreateUsersTable {
  Future<void> up() async {
    print('Starting database migration...');
    print('Connection details:');
    print('Host: ${DatabaseConfig.host}');
    print('Port: ${DatabaseConfig.port}');
    print('Database: ${DatabaseConfig.database}');
    print('Username: ${DatabaseConfig.username}');
    print('Is Production: ${DatabaseConfig.isProduction}');
    
    PostgreSQLConnection? connection;
    try {
      print('Initializing database connection...');
      connection = PostgreSQLConnection(
        DatabaseConfig.host,
        DatabaseConfig.port,
        DatabaseConfig.database,
        username: DatabaseConfig.username,
        password: DatabaseConfig.password
      );

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
      print('Creating new trigger...');
      await connection.query('''
        CREATE TRIGGER update_users_updated_at
        BEFORE UPDATE ON users
        FOR EACH ROW
        EXECUTE FUNCTION update_updated_at_column()
      ''');
      print('New trigger created successfully!');

      print('Migration completed successfully!');
    } catch (e, stackTrace) {
      print('Error during migration:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      print('Database URL format: ${DatabaseConfig.connectionString.replaceAll(RegExp(r':[^:@]+@'), ':***@')}');
      rethrow;
    } finally {
      if (connection != null) {
        print('Closing connection...');
        await connection.close();
        print('Connection closed successfully!');
      }
    }
  }

  Future<void> down() async {
    PostgreSQLConnection? connection;
    try {
      connection = PostgreSQLConnection(
        DatabaseConfig.host,
        DatabaseConfig.port,
        DatabaseConfig.database,
        username: DatabaseConfig.username,
        password: DatabaseConfig.password
      );

      await connection.open();
      await connection.query('DROP TABLE IF EXISTS users');
    } catch (e) {
      print('Error during down migration: $e');
      rethrow;
    } finally {
      if (connection != null) {
        await connection.close();
      }
    }
  }
}
