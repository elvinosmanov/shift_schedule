import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shift_schedule/api/sheets/schedule_sheets_api.dart';
import 'package:shift_schedule/models/employee.dart';
import 'package:shift_schedule/models/holidays.dart';

import '../database/database_helper.dart';
import '../enums/positions.dart';
import '../extensions/shift_status_extension.dart';
import '../methods/global_methods.dart';
import '../models/shift_model.dart';

class EmployeesProvider extends ChangeNotifier {
  bool _isCalendarView = false;

  bool get isCalendarView => _isCalendarView;

  set isCalendarView(bool value) {
    _isCalendarView = value;
    notifyListeners();
  }

  DateTime beginningOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  List<DailyShifts> dailyShiftsList = [];

  List<double> scrollOffsets = [];

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
    if (value != null) {
      DatabaseHelper.saveSelectedEmployee(value);
    }
    notifyListeners();
  }

  List<Holidays?> holidays = [];

  void getHolidays() async {
    List<Holidays> result = await DatabaseHelper.getHolidays();
    bool internetResult = await InternetConnectionChecker().hasConnection;

    if (result.isEmpty && internetResult) {
      result = await ScheduleSheetsApi.fetchHolidays();
      DatabaseHelper.saveHolidays(result);
    }
    holidays = result;
  }

  void getAllEmployees() async {
    bool hasUpdate = false;
    bool internetResult = await InternetConnectionChecker().hasConnection;

    if (internetResult == true) hasUpdate = await _checkUpdateStatus();

    final result = await DatabaseHelper.getEmployeeList();

    if (result.isNotEmpty && !hasUpdate) {
      employees = result;
    } else {
      employees = await ScheduleSheetsApi.fetchAllEmployees();
      DatabaseHelper.saveEmployeeList(employees);
    }
    if (employees.isNotEmpty) {
      await getSelectedEmployee();

      await calculateShift();
    }
  }

  Future<void> getSelectedEmployee() async {
    final result = await DatabaseHelper.getSelectedEmployee();
    if (result != null) {
      selectedEmployee = result;
    } else {
      selectedEmployee = employees[4];
    }
  }

  Future<bool> _checkUpdateStatus() async {
    final savedDate = await DatabaseHelper.getDate();
    final date = await ScheduleSheetsApi.fetchUpdatedDate();
    await ScheduleSheetsApi.fetchHolidays();
    if (date != savedDate) {
      DatabaseHelper.saveDate(date);
      return true;
    } else {
      return false;
    }
  }

  calculateShift() {
    DateTime today = DateTime.now();

    int beginningDayOfYear = beginningOfMonth.difference(DateTime(today.year, 1, 1)).inDays;
    int daysLeft = (12 - today.month) * 31;
    for (var i = 0; i < daysLeft - 1; i++) {
      DailyShifts dailyShifts = DailyShifts(date: beginningOfMonth.add(Duration(days: i)));
      for (var employee in employees) {
        final shiftStatus = employee.dates[beginningDayOfYear + i].statusToEnum;
        if (shiftStatus == ShiftStatus.day) {
          dailyShifts.dayShiftEmployee.add(employee);
        } else if (shiftStatus == ShiftStatus.night) {
          dailyShifts.nightShiftEmployee.add(employee);
        } else if (shiftStatus == ShiftStatus.regular) {
          dailyShifts.regularShiftEmployee.add(employee);
        } else if (shiftStatus == ShiftStatus.vacation) {
          dailyShifts.vacationShiftEmployee.add(employee);
        }
      }
      if (dailyShifts.dayShiftEmployee.length >= 2) {
        dailyShiftsList.add(dailyShifts);
      } else {
        break;
      }
    }
  }

  calculateScrollOfsset() {
    int index = 0;
    int count = 0;
    for (var dailyShift in dailyShiftsList) {
      int maxLength = max(
        dailyShift.dayShiftEmployee.length,
        dailyShift.nightShiftEmployee.length,
      );
      count += maxLength;
      index++;

      scrollOffsets.add(index * 54 + count * 36);
    }
  }

  bool isHolidayToday(DateTime date) {
    if (holidays.isNotEmpty) {
      return holidays.indexWhere((element) => GlobalMethods.isSameDate(element!.date, date)) >= 0;
    }
    return false;
  }

  // DateTime determineNextWorkingDay(DateTime now) {
  //   DateTime nextWorkingDay = now;

  //   // Loop until you find the next working day
  //   while (!isWorkingDay(nextWorkingDay)) {
  //     print('girdi');
  //     nextWorkingDay = nextWorkingDay.add(const Duration(days: 1));
  //   }

  //   return nextWorkingDay;
  // }

  // bool isWorkingDay(DateTime date) {
  //   final list =
  //       dailyShiftsList.where((element) => GlobalMethods.isSameDate(date, element.date)).toList();
  //   if (list == null) return false;
  //   return  list.first.dayShiftEmployee.isEmpty;
  // }
}
