
import '../enums/positions.dart';
import 'employee.dart';

class DailyShifts {
   DateTime date;
   List<Employee?> dayShiftEmployee = [];
   List<Employee?> nightShiftEmployee = [];
   List<Employee?> regularShiftEmployee = [];
  DailyShifts({
    required this.date,
  });
}

class ShiftModel {
   ShiftStatus? status;
   List<Employee?> employees = [];
  ShiftModel();
}