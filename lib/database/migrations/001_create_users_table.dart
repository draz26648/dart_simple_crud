import 'package:postgres/postgres.dart';

Future<void> createUsersTable(PostgreSQLConnection connection) async {
  await connection.execute('''
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      name VARCHAR(255) NOT NULL,
      gender VARCHAR(50) NOT NULL,
      age INTEGER NOT NULL,
      email VARCHAR(255) UNIQUE NOT NULL,
      mobile_number VARCHAR(50) NOT NULL
    )
  ''');
}
