import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:shift_schedule/methods/global_methods.dart';
import 'package:shift_schedule/ui/themes.dart';

import '../provider/employee_provider.dart';

class MyCalendarSchedule extends StatefulWidget {
  const MyCalendarSchedule({super.key});

  @override
  State<MyCalendarSchedule> createState() => _MyCalendarScheduleState();
}

class _MyCalendarScheduleState extends State<MyCalendarSchedule> {
  @override
  Widget build(BuildContext context) {
    final provider = context.read<EmployeesProvider>();
    final startWeekday = provider.dailyShiftsList[0].date.weekday - 1; //start from zero
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildDayName("MON"),
              _buildDayName("TUE"),
              _buildDayName("WED"),
              _buildDayName("THU"),
              _buildDayName("FRI"),
              _buildDayName("SAT"),
              _buildDayName("SUN"),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: GridView.builder(
              itemCount: provider.dailyShiftsList.length + startWeekday,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, // Number of columns in the grid
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                childAspectRatio: 0.6,
              ),
              itemBuilder: (context, gridIndex) {
                if (startWeekday > gridIndex) {
                  return Container();
                }
                final result = provider.dailyShiftsList[gridIndex - startWeekday];
                final isToday = GlobalMethods.isSameDate(DateTime.now(), result.date);
                Color color = Colors.grey[100]!;
                String shiftStatus = 'Off';
                int index = result.dayShiftEmployee.indexWhere(
                  (value) => value!.id == provider.selectedEmployee!.id,
                );
                if (index >= 0) {
                  color = kSunColorPri;
                  shiftStatus = 'Day';
                } else {
                  int index = result.nightShiftEmployee.indexWhere(
                    (value) => value!.id == provider.selectedEmployee!.id,
                  );
                  if (index >= 0) {
                    color = kNightColorPri;
                    shiftStatus = 'Night';
                  }
                }
                bool isHoliday = provider.isHolidayToday(result.date);

                return Container(
                  decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        width: isToday ? 2 : 0.5,
                        color: isToday ? Colors.red : Colors.black,
                      )),
                  child: Stack(
                    children: <Widget>[
                      if (isHoliday)
                        const Center(
                            child: CalendarIconWidget(
                          iconData: Icons.today,
                        )),
                      Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4.0, top: 4),
                            child: Text(DateFormat.d().format(result.date),
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                    fontSize: 20,
                                    height: 0.99,
                                    fontWeight: FontWeight.bold,
                                    color: shiftStatus == 'Night' ? Colors.white : Colors.black87,
                                  ),
                                )),
                          )),
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              shiftStatus,
                              style: GoogleFonts.lato(
                                  color: shiftStatus == 'Night' ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ))
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Expanded _buildDayName(String text) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        // margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        decoration: const BoxDecoration(
          color: kSunColorTR,
          // borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          text,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class CalendarIconWidget extends StatelessWidget {
  const CalendarIconWidget({
    Key? key,
    required this.iconData,
  }) : super(key: key);
  final IconData iconData;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
          border: Border.all(width: 0.5), shape: BoxShape.circle, color: Colors.white),
      child: Icon(
        iconData,
        color: Colors.red,
        size: 16,
      ),
    );
  }
}
