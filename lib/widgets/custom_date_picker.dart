
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shift_schedule/ui/themes.dart';

import '../provider/employee_provider.dart';

class CustomDatePicker extends StatelessWidget {
  const CustomDatePicker({
    super.key, required this.onDateChange,
  });

  final void Function(DateTime) onDateChange;
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeesProvider>();

    return DatePicker(
      DateTime.now(),
      daysCount: provider.dailyShiftsList.length,
      height: 80,
      width: 60,
      initialSelectedDate: DateTime.now(),
      selectionColor: kNightColorPri,
      selectedTextColor: Colors.white,
      dateTextStyle: GoogleFonts.lato(
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
      dayTextStyle: GoogleFonts.lato(
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
      monthTextStyle: GoogleFonts.lato(
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
      onDateChange: onDateChange
    );
  }
}
