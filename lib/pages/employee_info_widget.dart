import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shift_schedule/extensions/shift_status_extension.dart';

import '../enums/positions.dart';

class EmployeeInfoWidget extends StatelessWidget {
  const EmployeeInfoWidget({
    Key? key,
    required this.position,
    required this.name,
    required this.surname,
    required this.isDayShift,
  }) : super(key: key);
  final ShiftPosition position;
  final String name;
  final String surname;
  final bool isDayShift;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: position.getColor(isDayShift),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            position.toCustomString,
            style: GoogleFonts.lato(
              fontSize: 8,
              fontWeight: FontWeight.w400,
              color: const Color.fromARGB(255, 75, 72, 72),
            ),
          ),
          Text(
            '$name $surname',
            style: GoogleFonts.lato(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
