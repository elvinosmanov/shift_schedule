import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shift_schedule/methods/global_methods.dart';

class ScheduleDateWidget extends StatelessWidget {
  const ScheduleDateWidget({
    Key? key,
    required this.date,
  }) : super(key: key);
  final DateTime date;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      width: 60,
      child: Column(
        children: <Widget>[
          Text(
            DateFormat.d().add_E().format(date),
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
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
          if (GlobalMethods.isSameDate(date, DateTime.now())) _buildCurrentDayWidget('TODAY'),
          if (GlobalMethods.isSameDate(date, DateTime.now().add(const Duration(days: 1))))
            _buildCurrentDayWidget('TOMORROW')
        ],
      ),
    );
  }

  

  Container _buildCurrentDayWidget(String text) {
    return Container(
      width: 20,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.fromLTRB(2, 4, 2, 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blue[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: RotatedBox(
          quarterTurns: 3,
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          )),
    );
  }
}
