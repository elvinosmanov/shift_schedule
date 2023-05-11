import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shift_schedule/api/sheets/schedule_sheets_api.dart';
import 'package:shift_schedule/models/employee.dart';

import '../database/database_helper.dart';
import '../extensions/shift_status_extension.dart';
import '../models/shift_model.dart';

class EmployeesProvider extends ChangeNotifier {
  List<DailyShifts> dailyShiftsList = [];

  List<Employee> _employees = [];

  List<Employee> get employees => _employees;

  set employees(List<Employee> value) {
    _employees = value;
    notifyListeners();
  }

  Employee? _selectedEmployee;

  Employee? get selectedEmployee => _selectedEmployee;

  set selectedEmployee(Employee? value) {
    _selectedEmployee = value;
    notifyListeners();
  }

  void getAllEmployees() async {
    bool hasUpdate = false;
    final savedDate = await DatabaseHelper.getDate();
    final date = await ScheduleSheetsApi.fetchUpdatedDate();
    if (date != savedDate) {
      hasUpdate = true;
    } else {
      hasUpdate = false;
    }
    final result = await DatabaseHelper.getEmployeeList();
    print('resultin uzunlugu: ${result.length}');
    if (result.isNotEmpty && !hasUpdate) {
      employees = result;
    } else {
      employees = await ScheduleSheetsApi.fetchAllEmployees();
      DatabaseHelper.saveEmployeeList(employees);
      DatabaseHelper.saveDate(date);
    }
    if (employees.isNotEmpty) {
      selectedEmployee = employees[0];
    }
  }

  calculateShift() {
    DateTime today = DateTime.now();
    DateTime beginningOfMonth = DateTime(today.year, today.month, 1);
    int beginningDayOfYear = beginningOfMonth.difference(DateTime(today.year, 1, 1)).inDays;
    int daysLeft = (12 - today.month) * 31;
    for (var i = 0; i < daysLeft - 1; i++) {
      DailyShifts dailyShifts = DailyShifts(date: beginningOfMonth.add(Duration(days: i)));
      for (var employee in employees) {
        print(employee.dates.length);
        final shiftStatus = employee.dates[beginningDayOfYear + i].convertToEnum;
        if (shiftStatus == ShiftStatus.day) {
          dailyShifts.dayShiftEmployee.add(employee);
        } else if (shiftStatus == ShiftStatus.night) {
          dailyShifts.nightShiftEmployee.add(employee);
        } else if (shiftStatus == ShiftStatus.regular) {
          dailyShifts.regularShiftEmployee.add(employee);
        }
      }
      if (dailyShifts.dayShiftEmployee.length >= 2) {
        dailyShiftsList.add(dailyShifts);
      }
       else {
        print('break oldu');
        break;
      }
    }
  }
}
