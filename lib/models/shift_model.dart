
import '../enums/positions.dart';
import 'employee.dart';

class DailyShifts {
   DateTime date;
   Map<ShiftStatus, List<Employee>> shiftEmployees = generateMapWithEmptyLists();
  //  List<Employee?> dayShiftEmployee = [];
  //  List<Employee?> nightShiftEmployee = [];
  //  List<Employee?> nightInShiftEmployee = [];
  //  List<Employee?> nightOutShiftEmployee = [];
  //  List<Employee?> regularShiftEmployee = [];
  //  List<Employee?> regularShortShiftEmployee = [];
  //  List<Employee?> vacationShiftEmployee = [];
  DailyShifts({
    required this.date,
  });

  @override
  String toString() => 'DailyShifts(date: $date, employees: $shiftEmployees)';
}

class ShiftModel {
   ShiftStatus? status;
   List<Employee?> employees = [];
  ShiftModel();
}