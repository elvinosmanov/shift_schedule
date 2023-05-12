import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shift_schedule/extensions/shift_status_extension.dart';

import 'package:shift_schedule/ui/themes.dart';

import '../models/employee.dart';
import '../pages/employee_info_widget.dart';

class EmployeeScheduleCards extends StatelessWidget {
  const EmployeeScheduleCards({
    Key? key,
    required this.isDayShift,
    required this.employees,
  }) : super(key: key);
  final bool isDayShift;
  final List<Employee?> employees;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDayShift ? kSunColorPri : kNightColorPri,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              isDayShift ? "DAY SHIFT" : "NIGHT SHIFT",
              style: GoogleFonts.lato(
                color: Colors.white,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          if (employees.isNotEmpty)
            Column(
              children: employees.map((emp) {
                return EmployeeInfoWidget(
                  isDayShift: isDayShift,
                  name: emp!.firstName,
                  surname: emp.lastName,
                  position: emp.role.positionToEnum,
                );
              }).toList(),
            )
        ],
      ),
    );
  }
}
