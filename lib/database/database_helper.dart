import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/employee.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;
  static String filePath = 'employees.db';
  DatabaseHelper._init();

  Future<Database> get database async {
    print('database in icerisine girir');
    if (_database != null) {
      return _database!;
    }
    print('init dbni cagiracaq');
    _database = await _initDB();
    print(_database!.isOpen);
    print('cagirdi');
    return _database!;
  }

  Future<Database> _initDB() async {
    // deleteDatabase(filePath);
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE employees(
  id INTEGER,
  first_name TEXT,
  last_name TEXT,
  role TEXT,
  dates TEXT
)
''');
  }

  Future<void> deleteDatabases() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, filePath);
    await deleteDatabase(path);
  }

  Future<int> createEmployee(Employee employee) async {
    final db = await instance.database;

    return await db.insert('employees', {
      'id': employee.id,
      'first_name': employee.firstName,
      'last_name': employee.lastName,
      'role': employee.role,
      'dates': employee.dates.join(','),
    });
  }

  Future<int> createUpdatedDate(int date) async {
    final db = await instance.database;

    return await db.insert('date', {"updatedDate": date});
  }

  Future<int> getUpdatedDate() async {
    final db = await instance.database;
    final result = await db.query('date') as Map;
    return int.parse(result['updatedDate'].toString());
  }

  Future<int> createEmployeeFromList(List<String> dataList) async {
    final db = await instance.database;
    String fullName = dataList[1];

    // Split full name by whitespace and assume first part is first name, rest is last name
    List<String> nameParts = fullName.split(" ");
    String firstName = nameParts[0];
    String lastName = nameParts.sublist(1).join(" ");

    return await db.insert('employees', {
      'id': int.parse(dataList[0]),
      'first_name': firstName,
      'last_name': lastName,
      'role': dataList[2],
      'dates': dataList.sublist(3).join(','),
    });
  }

  Future<int> updateEmployeeFromList(List<String> dataList) async {
    final db = await instance.database;
    String fullName = dataList[1];

    // Split full name by whitespace and assume first part is first name, rest is last name
    List<String> nameParts = fullName.split(" ");
    String firstName = nameParts[0];
    String lastName = nameParts.sublist(1).join(" ");
    return await db.update(
        'employees',
        {
          'id': int.parse(dataList[0]),
          'first_name': firstName,
          'last_name': lastName,
          'role': dataList[2],
          'dates': dataList.sublist(3).join(','),
        },
        where: 'id = ?',
        whereArgs: [dataList[0]]);
  }

  Future<int> updateEmployee(Employee employee) async {
    final db = await instance.database;

    return await db.update(
        'employees',
        {
          'id': employee.id,
          'first_name': employee.firstName,
          'last_name': employee.lastName,
          'role': employee.role,
          'dates': employee.dates.join(','),
        },
        where: 'id = ?',
        whereArgs: [employee.id]);
  }

  Future<List<Employee>> getAllEmployees() async {
    final db = await instance.database;
    // final db = await openDatabase(path, version: 1, onCreate: _createDB);

    final result = await db.query('employees');
    print(result);
    return result.map((json) => Employee.fromJson(json)).toList();
  }

  Future<Employee> getEmployeeByName(String name) async {
    final Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'employees',
      where: 'first_name = ? OR last_name = ?',
      whereArgs: [name, name],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return Employee.fromJson(result.first);
    } else {
      throw Exception('Employee not found');
    }
  }

  Future<List<String>> getAllEmployeesNamesAndInitials() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('employees');
    final List<String> employees = [];

    for (final map in maps) {
      final String name = map['first_name'];
      final String lastName = map['last_name'];
      final String initial = lastName.isEmpty ? '' : lastName[0];

      employees.add('$name $initial.');
    }

    return employees;
  }

  Future<int> deleteEmployee(int id) async {
    final db = await instance.database;

    return await db.delete('employees', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> doesDatabaseExist() async {
    String path = join(await getDatabasesPath(), filePath);
    return databaseExists(path);
  }
}
