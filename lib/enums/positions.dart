import 'package:shift_schedule/models/employee.dart';

enum ShiftStatus { day, night, nightOut, nightIn, regular, regularShort, holidayDay, holidayIn, holidayOut, vacation, off }
Map<ShiftStatus, List<Employee>> generateMapWithEmptyLists() {
  final map = <ShiftStatus, List<Employee>>{};
  
  for (var enumValue in ShiftStatus.values) {
    map[enumValue] = [];
  }
  
  return map;
}

enum ShiftPosition { shiftLeader, shiftController, shiftTrainer, engineer }



void main() {
  print(ShiftStatus.day.toString());
  print(ShiftStatus.night.toString());
  print(ShiftStatus.regularShort.toString());
}



