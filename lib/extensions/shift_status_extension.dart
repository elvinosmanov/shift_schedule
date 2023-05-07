import 'package:shift_schedule/models/employee.dart';

enum ShiftStatus { day, night, nightOut, nightIn, regular, regularShort, vacation, off }

extension StringShiftStatusExtension on String {
  ShiftStatus get convertToEnum {
    if (this == "D") return ShiftStatus.day;
    if (this == "N" || this == "_N") return ShiftStatus.night;
    // if (this == "N_") return ShiftStatus.nightOut;
    // if (this == "_N") return ShiftStatus.nightIn;
    if (this == "R") return ShiftStatus.regular;
    if (this == "RS" || this == 'SR') return ShiftStatus.regularShort;
    if (this == "V") return ShiftStatus.vacation;
    return ShiftStatus.off;
  }

  // add more methods as needed
}
