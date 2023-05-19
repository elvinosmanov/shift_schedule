
import '../enums/positions.dart';
import 'employee.dart';

class DailyShifts {
   DateTime date;
   List<Employee?> dayShiftEmployee = [];
   List<Employee?> nightShiftEmployee = [];
   List<Employee?> regularShiftEmployee = [];
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