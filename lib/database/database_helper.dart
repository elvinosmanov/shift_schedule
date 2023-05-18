
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shift_schedule/models/employee.dart';

import '../models/holidays.dart';

class DatabaseHelper {

static Future<void> saveEmployeeList(List<Employee> employeeList) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Convert list of employee model to list of Map
  List<Map<String, dynamic>> employeeMapList = employeeList.map((e)=>e.toMap()).toList();

  // Convert list of Map to string
  String employeeString = json.encode(employeeMapList);

  // Save string to SharedPreferences
  await prefs.setString('employeeList', employeeString);
}

static Future<List<Employee>> getEmployeeList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Get string from SharedPreferences
  String? employeeString = prefs.getString('employeeList');

  if (employeeString != null) {
    // Convert string to list of Map
    List<Map<String, dynamic>> employeeMapList = json.decode(employeeString).cast<Map<String, dynamic>>();

    // Convert list of Map to list of employee model
    List<Employee> employeeList = employeeMapList.map((e) => Employee.fromJson(e)).toList();

    return employeeList;
  } else {
    return [];
  }
}


  static void saveDate(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('myInt', value);
  }

// Get an integer value
  static Future<int> getDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('myInt') ?? 0; // Return 0 if the value is not set
  }

  static void saveHolidays(List<Holidays?> holidays) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
  List<Map<String, dynamic>> holidayMapList = holidays.map((e)=>e!.toMap()).toList();
  final holidayString = json.encode(holidayMapList);

    await prefs.setString('holidayList', holidayString);
  }

  static Future<List<Holidays>> getHolidays() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? holidayString = prefs.getString('holidayList');

  if (holidayString != null) {
    List<Map<String, dynamic>> holidayMapList = json.decode(holidayString).cast<Map<String, dynamic>>();

    List<Holidays> holidayList = holidayMapList.map((e) => Holidays.fromMap(e)).toList();

    return holidayList;
  } else {
    return [];
  }
  }


}