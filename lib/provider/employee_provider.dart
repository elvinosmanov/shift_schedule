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
  bool _uploadLoading = false;

  bool get uploadLoading => _uploadLoading;

  set uploadLoading(bool value) {
    _uploadLoading = value;
    notifyListeners();
  }

  bool _hasUpdate = false;

  bool get hasUpdate => _hasUpdate;

  set hasUpdate(bool value) {
    _hasUpdate = value;
    notifyListeners();
  }

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

  List<Map<String, int>> shiftCount = [];


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
  List<int?> monthlyHours = [];

  void init() {
    getAllEmployees();
    getHolidays();
    getMonthlyHours();
    checkUpdateStatus();
  }

  void getHolidays() async {
    List<Holidays> result = await DatabaseHelper.getHolidays();
    if (result.isEmpty) {
      await fetchHolidays();
    } else {
      holidays = result;
    }
  }

  void getMonthlyHours() async {
    var result = await DatabaseHelper.getMonthlyHours();
    if (result.isEmpty) {
      await fetchMonthlyHours();
    } else {
      monthlyHours = result;
    }
  }

  Future<void> fetchMonthlyHours() async {
    bool internetResult = await InternetConnectionChecker().hasConnection;
    if (internetResult) {
      monthlyHours = await ScheduleSheetsApi.fetchMonthlyHours();
      DatabaseHelper.saveMonthlyHours(monthlyHours);
    }
  }

  Future<void> fetchHolidays() async {
    bool internetResult = await InternetConnectionChecker().hasConnection;

    if (internetResult) {
      holidays = await ScheduleSheetsApi.fetchHolidays();
      DatabaseHelper.saveHolidays(holidays);
    }
  }

  void getAllEmployees() async {
    bool internetResult = await InternetConnectionChecker().hasConnection;
    final result = await DatabaseHelper.getEmployeeList();

    if (result.isNotEmpty) {
      employees = result;
    } else {
      if (internetResult) {
        fetchEmployees();
      }
    }
    if (employees.isNotEmpty) {
      await getSelectedEmployee();
      await calculateShift();
    }
  }

  Future<void> fetchEmployees() async {
    employees = await ScheduleSheetsApi.fetchAllEmployees();
    DatabaseHelper.saveEmployeeList(employees);
  }

  Future<void> getSelectedEmployee() async {
    final result = await DatabaseHelper.getSelectedEmployee();
    if (result != null) {
      selectedEmployee = result;
    } else {
      selectedEmployee = employees[0];
    }
  }

  checkUpdateStatus() async {
    bool internetResult = await InternetConnectionChecker().hasConnection;
    if (!internetResult) return;
    final savedDate = await DatabaseHelper.getDate();
    final date = await ScheduleSheetsApi.fetchUpdatedDate();
    if (date != savedDate) {
      // fetchEmployees();
      // calculateShift();
      DatabaseHelper.saveDate(date);
      // await ScheduleSheetsApi.fetchHolidays();
      hasUpdate = true;
    }
  }

  calculateShift() {
    dailyShiftsList = [];
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
        } else if (shiftStatus == ShiftStatus.nightIn) {
          dailyShifts.nightInShiftEmployee.add(employee);
        } else if (shiftStatus == ShiftStatus.nightOut) {
          dailyShifts.nightOutShiftEmployee.add(employee);
        } else if (shiftStatus == ShiftStatus.regular) {
          dailyShifts.regularShiftEmployee.add(employee);
        } else if (shiftStatus == ShiftStatus.regularShort) {
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

  updateDatabase() async {
    uploadLoading = true;
    fetchHolidays();
    fetchMonthlyHours();
    await fetchEmployees();
    calculateShift();
    uploadLoading = false;
    hasUpdate = false;
  }
}
