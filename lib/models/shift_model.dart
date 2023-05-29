
import '../enums/positions.dart';
import 'employee.dart';

class DailyShifts {
   DateTime date;
   Map<ShiftStatus, List<Employee>> shiftEmployees = generateMapWithEmptyLists();
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