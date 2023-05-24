import 'package:shift_schedule/enums/positions.dart';

class ShiftMonthlyCount {
  final List<ShiftMonthlyCount> shiftDayCountList;
  final int month;

  ShiftMonthlyCount({required this.shiftDayCountList, required this.month});
}

class ShiftDayCount {
  final ShiftStatus status;
  final int count;

  ShiftDayCount({required this.status, this.count = 0});
}
