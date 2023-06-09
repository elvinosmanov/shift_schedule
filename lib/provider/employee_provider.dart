import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shift_schedule/api/sheets/schedule_sheets_api.dart';
import 'package:shift_schedule/models/employee.dart';
import 'package:shift_schedule/models/holidays.dart';

import '../database/database_helper.dart';
import '../enums/positions.dart';
import '../extensions/shift_status_extension.dart';
import '../methods/global_methods.dart';
import '../models/shift_model.dart';

class EmployeesProvider extends ChangeNotifier {
  bool internetResult = true;
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
  List<DailyShifts> _dailyShiftsList = [];

  List<DailyShifts> get dailyShiftsList => _dailyShiftsList;

  set dailyShiftsList(List<DailyShifts> value) {
    _dailyShiftsList = value;
    notifyListeners();
  }

  List<double> scrollOffsets = [];

  List<Employee> _employees = [];

  List<Employee> get employees => _employees;

  List<List<Map<ShiftStatus, int>>> shiftCount = [];

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

  Future<void> init() async {
    await checkInternet();
    await getHolidays();
    await getMonthlyHours();
    await getAllEmployees();
    checkUpdateStatus();
  }

  checkInternet() async {
    if (!kIsWeb) {
      final connectivityResult = await (Connectivity().checkConnectivity());
      internetResult = connectivityResult != ConnectivityResult.none;
    }
  }

  Future<void> getHolidays() async {
    List<Holidays> result = await DatabaseHelper.getHolidays();
    if (result.isEmpty) {
      await fetchHolidays();
    } else {
      holidays = result;
    }
  }

  Future<void> getMonthlyHours() async {
    var result = await DatabaseHelper.getMonthlyHours();
    if (result.isEmpty) {
      await fetchMonthlyHours();
    } else {
      monthlyHours = result;
    }
  }

  Future<void> fetchMonthlyHours() async {
    if (internetResult) {
      monthlyHours = await ScheduleSheetsApi.fetchMonthlyHours();
      DatabaseHelper.saveMonthlyHours(monthlyHours);
    }
  }

  Future<void> fetchHolidays() async {
    if (internetResult) {
      holidays = await ScheduleSheetsApi.fetchHolidays();
      DatabaseHelper.saveHolidays(holidays);
    }
  }

  Future<void> getAllEmployees() async {
    final result = await DatabaseHelper.getEmployeeList();

    if (result.isNotEmpty) {
      employees = result;
    } else {
      if (internetResult) {
        await fetchEmployees();
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
    if (!internetResult) return;
    final savedDate = await DatabaseHelper.getDate();
    final date = await ScheduleSheetsApi.fetchUpdatedDate();
    if (date != savedDate) {
      DatabaseHelper.saveDate(date);
      hasUpdate = true;
    }
  }

  calculateShift() {
    dailyShiftsList = [];
    DateTime today = DateTime.now();

    int beginningDayOfYear = beginningOfMonth.difference(DateTime(today.year, 1, 1)).inDays;
    int daysLeft = (12 - today.month) * 31;
    // List<Map<String, List<Employee?>?>> alma = [];
    shiftCount = List.generate(employees.length, (index) => [{}, {}]);
    for (var i = 0; i < daysLeft - 1; i++) {
      final currentDate = beginningOfMonth.add(Duration(days: i));

      DailyShifts dailyShifts = DailyShifts(date: currentDate);
      int index = 0;
      for (Employee employee in employees) {
        final shiftStatus = employee.dates[beginningDayOfYear + i].statusToEnum;
        dailyShifts.shiftEmployees.update(
          shiftStatus,
          (value) => value..add(employee),
          ifAbsent: () => [employee],
        );
        fillShiftCount(
            index: index, date: currentDate, shift: checkShiftForHoliday(currentDate, shiftStatus));
        index++;
      }
      if (dailyShifts.shiftEmployees.containsKey(ShiftStatus.day) &&
          dailyShifts.shiftEmployees[ShiftStatus.day]!.length >= 2) {
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
        dailyShift.shiftEmployees[ShiftStatus.day]!.length,
        (dailyShift.shiftEmployees[ShiftStatus.night]!.length +
            dailyShift.shiftEmployees[ShiftStatus.nightIn]!.length),
      );
      count += maxLength;
      index++;

      scrollOffsets.add(index * 54 + count * 36);
    }
  }

  bool isHolidayToday(DateTime date) {
    final findIndex =
        holidays.indexWhere((element) => GlobalMethods.isSameDate(element!.date, date));
    return findIndex >= 0;
  }

  updateDatabase() async {
    shiftCount = List.generate(employees.length, (index) => [{}, {}]);
    uploadLoading = true;
    fetchHolidays();
    fetchMonthlyHours();
    await fetchEmployees();
    calculateShift();
    uploadLoading = false;
    hasUpdate = false;
  }

  void fillShiftCount({required DateTime date, required ShiftStatus shift, required int index}) {
    // print(shift);
    if (beginningOfMonth.month == date.month) {
      shiftCount[index][0].update(
        shift,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    } else {
      shiftCount[index][1].update(
        shift,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
  }

  ShiftStatus checkShiftForHoliday(DateTime date, ShiftStatus shift) {
    if (isHolidayToday(date) == true) {
      if (shift == ShiftStatus.day || shift == ShiftStatus.night) {
        shift = ShiftStatus.holidayDay;
      } else if (shift == ShiftStatus.nightIn) {
        shift = ShiftStatus.holidayIn;
      } else if (shift == ShiftStatus.nightOut) {
        shift = ShiftStatus.holidayOut;
      }
    }
    return shift;
  }
}
