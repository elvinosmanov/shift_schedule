import 'package:flutter/material.dart';
import 'package:shift_schedule/ui/themes.dart';

import '../enums/positions.dart';

extension StringShiftStatusExtension on String {
  ShiftPosition get positionToEnum {
    switch (this) {
      case 'SL':
        return ShiftPosition.shiftLeader;
      case 'SC':
        return ShiftPosition.shiftController;
      case 'TR':
        return ShiftPosition.shiftTrainer;
      default:
        return ShiftPosition.engineer;
    }
  }

  ShiftStatus get statusToEnum {
    if (this == "D") return ShiftStatus.day;
    if (this == "N") return ShiftStatus.night;
    if (this == "N_") return ShiftStatus.nightOut;
    if (this == "_N") return ShiftStatus.nightIn;
    if (this == "R") return ShiftStatus.regular;
    if (this == "RS" || this == 'SR') return ShiftStatus.regularShort;
    if (this == "v") return ShiftStatus.vacation;

    return ShiftStatus.off;
  }

  // add more methods as needed
}

extension PositionEnumExtension on ShiftPosition {
  String get toCustomString {
    switch (this) {
      case ShiftPosition.shiftLeader:
        return 'Shift Leader';
      case ShiftPosition.shiftController:
        return 'Shift Controller';
      case ShiftPosition.shiftTrainer:
        return 'Shift Trainer';
      case ShiftPosition.engineer:
        return 'Engineer';
      default:
        return 'Employee'; // Handle any other cases if needed
    }
  }

  Color getColor(bool isDayShift) {
    switch (this) {
      case ShiftPosition.shiftLeader:
        return isDayShift ? kSunColorSL : kNightColorSL;
      case ShiftPosition.shiftController:
        return isDayShift ? kSunColorSC : kNightColorSC;
      case ShiftPosition.shiftTrainer:
        return isDayShift ? kSunColorTR : kNightColorTR;
      default:
        return isDayShift ? kSunColorTR : kNightColorTR; // Handle any other cases if needed
    }
  }
}

extension ShiftStatusExtension on ShiftStatus {
  String toStr() {
    switch (this) {
      case ShiftStatus.day:
        return 'Day Shift';
      case ShiftStatus.night:
        return 'Night Shift';
      case ShiftStatus.nightIn:
        return 'Night In Shift';
      case ShiftStatus.nightOut:
        return 'Night Out Shift';
      case ShiftStatus.regular:
        return 'Regular Shift';
      case ShiftStatus.regularShort:
        return 'Short Regular Shift';
      case ShiftStatus.holidayDay:
        return 'Holiday';
      case ShiftStatus.holidayIn:
        return 'Holiday In';
      case ShiftStatus.holidayOut:
        return 'Holiday Out';
      case ShiftStatus.vacation:
        return 'Vacation';
      case ShiftStatus.off:
        return 'Off Day';
    }
  }
  String toShortStr() {
    switch (this) {
      case ShiftStatus.day:
        return 'Day';
      case ShiftStatus.night:
        return 'Night';
      case ShiftStatus.nightIn:
        return 'In';
      case ShiftStatus.nightOut:
        return 'Out';
      case ShiftStatus.regular:
        return 'Reg';
      case ShiftStatus.regularShort:
        return 'SReg';
      case ShiftStatus.holidayDay:
        return 'Holiday';
      case ShiftStatus.holidayIn:
        return 'Holiday In';
      case ShiftStatus.holidayOut:
        return 'Holiday Out';
      case ShiftStatus.vacation:
        return 'Vac';
      case ShiftStatus.off:
        return 'Off';
    }
  }
}
