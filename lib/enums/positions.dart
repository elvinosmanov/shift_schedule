enum ShiftStatus { day, night, nightOut, nightIn, regular, regularShort, holidayDay, holidayIn, holidayOut, vacation, off }

enum ShiftPosition { shiftLeader, shiftController, shiftTrainer, engineer }



void main() {
  print(ShiftStatus.day.toString());
  print(ShiftStatus.night.toString());
  print(ShiftStatus.regularShort.toString());
}



