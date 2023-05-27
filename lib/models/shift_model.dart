
import '../enums/positions.dart';
import 'employee.dart';

class DailyShifts {
   DateTime date;
   List<Map<String, dynamic>> shiftEmployees = [];
   List<Employee?> dayShiftEmployee = [];
   List<Employee?> nightShiftEmployee = [];
   List<Employee?> nightInShiftEmployee = [];
   List<Employee?> nightOutShiftEmployee = [];
   List<Employee?> regularShiftEmployee = [];
   List<Employee?> regularShortShiftEmployee = [];
   List<Employee?> vacationShiftEmployee = [];
  DailyShifts({
    required this.date,
  });
}

class ShiftModel {
   ShiftStatus? status;
   List<Employee?> employees = [];
  ShiftModel();
}