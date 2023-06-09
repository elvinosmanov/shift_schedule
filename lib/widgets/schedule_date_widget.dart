import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:shift_schedule/enums/positions.dart';
import 'package:shift_schedule/methods/global_methods.dart';
import 'package:shift_schedule/provider/employee_provider.dart';
import 'package:shift_schedule/ui/themes.dart';

class ScheduleDateWidget extends StatelessWidget {
  const ScheduleDateWidget({
    Key? key,
    required this.status,
    required this.date,
  }) : super(key: key);
  final DateTime date;
  final ShiftStatus status;
  @override
  Widget build(BuildContext context) {
    bool isHoliday = context.read<EmployeesProvider>().isHolidayToday(date);
    bool isWeekend = (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday);
    final hasController = status != ShiftStatus.off;
    final isDay = status == ShiftStatus.day;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      width: 60,
      child: Column(
        children: <Widget>[
          Container(
            padding: hasController ? const EdgeInsets.all(2) : EdgeInsets.zero,
            decoration: BoxDecoration(
              border: Border.all(
                  color: hasController
                      ? isDay
                          ? kSunColorSL
                          : kNightColorSL
                      : Colors.transparent,
                  width: hasController ? 1.5 : 0.0),
              borderRadius: BorderRadius.circular(hasController ? 4 : 0),
            ),
            child: Column(
              children: <Widget>[
                Text(
                  DateFormat.d().add_E().format(date),
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isWeekend ? Colors.red : Colors.grey[500],
                  ),
                ),
                Text(
                  DateFormat.MMMM().format(date),
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (isHoliday) _buildCurrentDayWidget('Holiday', Colors.red, Colors.white),
              if (GlobalMethods.isSameDate(date, DateTime.now())) _buildCurrentDayWidget('TODAY'),
              if (GlobalMethods.isSameDate(date, DateTime.now().add(const Duration(days: 1))))
                _buildCurrentDayWidget('TOMORROW')
            ],
          )
        ],
      ),
    );
  }

  Container _buildCurrentDayWidget(
    String text, [
    Color? backgroundColor,
    Color? textColor,
  ]) {
    return Container(
      width: 20,
      margin: const EdgeInsets.only(top: 4, left: 2, right: 2),
      padding: const EdgeInsets.fromLTRB(2, 4, 2, 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.blue[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: RotatedBox(
          quarterTurns: 3,
          child: Text(
            text,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w600, color: textColor ?? Colors.black),
          )),
    );
  }
}
