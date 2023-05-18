import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';
import 'package:shift_schedule/models/employee.dart';
import 'package:shift_schedule/models/holidays.dart';

class ScheduleSheetsApi {
  static const _credentials = r'''
{
  "type": "service_account",
  "project_id": "xenon-world-337610",
  "private_key_id": "657007a73eb6a64f3fceb930b8db50567519357e",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEuwIBADANBgkqhkiG9w0BAQEFAASCBKUwggShAgEAAoIBAQC+0W7ddDSJYB6y\nxzddNjDdI00km0VkxFIUurhIeg1Q4pQ02vk/6skOWwxJ9A5dX9Gdz7ld3z9XXOd/\n7QPQ4uS9w3XIj9m5m351nVmh0WY7PyiCU18EUEPzaqZDlcRZ6QI4em7MR8pplPgz\npNZEnt/A6ubMKsu1HHphqKvaw31cVQfLwKxG6bczPZSiLzaGKXhZ6//2kv2vfWx0\nSSCiqCC5aKUKDd2kLq2U9FFfU36vj8uvtlvCq1BqqOc5z8pdjGen2jI6/o3e2e37\n5sus7lC6WVW7fGrGOs6Tg8SuIq/7FKIGorlU+GM54G6bxaxNLTIgb9c4C7Wx2TwV\nTJOkyenrAgMBAAECgf8CPHIQJkx3T6kMb0k2zmvEK6W7yBYIGETd+VIvhz6gtAcI\nl4hUN2wjvu1l8HY6oeTS9Jw3fWZAn9YWqbBhwkbr8l5u+0CR7ECPIEjsnIeWKidP\nX6q9YjNpptZL9HVYmGJuRwEFY9H7asN913CrXTFCEX6i5d19QdgtTMy2w5O0gUVn\n8eEuyVbBzMO3JookKilLv5Orf6ZRWd6nYnfYN70LYOtdaaioe32VDjJUvNJbgzCR\nVHjxY8MQCDLwfut9pv3qoPA6NeM6c1hp2FLLVzCfEL0L1d4TlxZEoRBivfmLNMIn\nlA3wwysFG54VHBIdqO5VtihfcOufBQCeWt3SkXkCgYEA3xVL2nKZTxOG7WwJQyf+\n2NaLEPqJvZqIBJRgQQEKwzVcjNyk2gA6nWvILJwN+x+hA6Qh/XfuQoug53s2xzun\nCcISSbDG/r5SOBk/XONoHX7GvCV5ltzSOfhhCeA83fx3ho4dfQHG8xwYWlhd/Bk2\n5xVD67hYAFF363SZBi9XBp0CgYEA2vlccZt5Ob6KJegQL8y7eDXBIKBDT7+QEh+J\nIWcWRyS52Lu8Uu08tU/prnON0MjAFonmRwErkfCcV4NPrvERgrDUSigtvwOsFtJo\njZDc4SXJOrpfhhev9gixDt5xuZnYp1vIurgoLVuRrrAFR6BHoNRXOaHwBWWBb4I0\n06WvCCcCgYAW5RKh2r0NNo3UdBAHSmWHT416MpxMTz3Cao/uW/ME0ccr1cE9dmSN\nn3At095DdZ2KyB+M6fAT+EyNNUIL9H1SLQ6/bVse7d12UHEGUXhv/oDa8mWmLAeP\nV4RuBQt6JN0HfDJej/4hGTMOop8SrmvKD46m9IZjkfjiu1axIc6mqQKBgHLC24Mi\n826jAK4LKGiUyO+gZH4f4Acso2oMIwdhiphwlAIVqgZgFUAFCLiIERwKCjoFva0a\n3OXYj2eCB0HtT7sJx8ixs//3AbrYPTlsYYaSEht4T9XsFilAtuLPDBU0nwpfHR1W\npJ/Y7Mn7sFiwlLmib7BhwXRilWqGd/8wR0JjAoGBAI6a3ZIhLBbwErnfFN+6MHcE\n38KvqV1ulzKVKeEqDhQ91YNGeLs2ZCGuJD8a1hJ3iO0y3yJPe9jFVfd/+5kmqJL9\ngm3urIZy3pLW7noGcJBp3WCtXbD3PFXr7K2sTF6iAIwgdWEf/E44c9kwiXEJ8756\nLiG1Nh/4CE4HoBXKdXLE\n-----END PRIVATE KEY-----\n",
  "client_email": "schedule@xenon-world-337610.iam.gserviceaccount.com",
  "client_id": "110248552499424285348",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/schedule%40xenon-world-337610.iam.gserviceaccount.com"
}
''';
  static const _spreadsheetId = '1u7uisW0JZjJxONH6Liu9Fg6cnD7mWcyJAT8EtB09vCA';

  static final _gsheets = GSheets(_credentials);

  static Future fetchAllEmployees() async {
    final spreadsheet = await _gsheets.spreadsheet(_spreadsheetId);
    final scheduleSheet = _getWorkSheet(spreadsheet, title: 'Sheet1');

    try {
      var values = await scheduleSheet.values.allRows();
      // var numRows = values.length;
      List<Employee> employeeList = [];
      for (var i = 1; i < int.parse(values.last.first); i++) {
        final dataList = await scheduleSheet.values.rowByKey(i, fromColumn: 1);
        employeeList.add(Employee.fromList(dataList!));
      }
      return employeeList;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future fetchUpdatedDate() async {
    final spreadsheet = await _gsheets.spreadsheet(_spreadsheetId);
    final scheduleSheet = _getWorkSheet(spreadsheet, title: 'Sheet1');

    try {
      var values = await scheduleSheet.values.value(row: 2, column: 1);
      // var values = await scheduleSheet.cells.cell(row: 2, column: 1);
      int date = int.parse(values);
      return date;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<List<Holidays>> fetchHolidays() async {
    final spreadsheet = await _gsheets.spreadsheet(_spreadsheetId);
    final scheduleSheet = _getWorkSheet(spreadsheet, title: 'holidays');

    try {
      List<Holidays> holidays=[];
      var values = await scheduleSheet.values.allRows();
      for (var value in values) {
        holidays.add(Holidays.fromList(value));
      }

      return holidays;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  static Worksheet _getWorkSheet(Spreadsheet spreadsheet, {required String title}) {
    return spreadsheet.worksheetByTitle(title)!;
  }
}
