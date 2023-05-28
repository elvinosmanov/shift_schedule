import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shift_schedule/enums/positions.dart';
import 'package:shift_schedule/extensions/shift_status_extension.dart';

import 'package:shift_schedule/methods/global_methods.dart';
import 'package:shift_schedule/models/shift_model.dart';
import 'package:shift_schedule/ui/themes.dart';

import '../models/employee.dart';
import '../provider/employee_provider.dart';

class MyCalendarSchedule extends StatefulWidget {
  const MyCalendarSchedule({super.key});

  @override
  State<MyCalendarSchedule> createState() => _MyCalendarScheduleState();
}

class _MyCalendarScheduleState extends State<MyCalendarSchedule> {
  ShiftStatus whichShiftStatus(Map<ShiftStatus, List<Employee>> map) {
    final selectedEmployee = context.watch<EmployeesProvider>().selectedEmployee!;
    for (final entry in map.entries) {
      final employeeList = entry.value;
      if (employeeList.contains(selectedEmployee)) {
        return entry.key;
      }
    }
    return ShiftStatus.off;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<EmployeesProvider>();
    // provider.shiftCount = [{}, {}];
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
              _buildDayName("SAT", Colors.red),
              _buildDayName("SUN", Colors.red),
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
                final dailyShift = provider.dailyShiftsList[gridIndex - startWeekday];
                bool isHoliday = provider.isHolidayToday(dailyShift.date);
                final isToday = GlobalMethods.isSameDate(DateTime.now(), dailyShift.date);
                Color color = Colors.grey[100]!;
                // String shiftStatus = 'Off';
                // var shift = ShiftStatus.off;

                final shiftStatus = whichShiftStatus(dailyShift.shiftEmployees);
                final Color textColor =
                    shiftStatus == ShiftStatus.night ? Colors.white : Colors.black;
                switch (shiftStatus) {
                  case ShiftStatus.day:
                    color = kSunColorPri;
                    break;
                  case ShiftStatus.nightIn:
                    print('yes');
                    color = kNightColorSL;
                    break;
                  case ShiftStatus.nightOut:
                    print('yes');
                    color = kNightColorSL.withOpacity(0.4);
                    break;
                  case ShiftStatus.night:
                    color = kNightColorPri;
                    break;
                  case ShiftStatus.regular:
                    color = Colors.green[200]!;
                    break;
                  case ShiftStatus.vacation:
                    color = const Color.fromARGB(255, 177, 120, 243);
                    break;
                  default:
                    color = Colors.grey[100]!;
                }
                // int index = dailyShift.dayShiftEmployee.indexWhere(
                //   (value) => value!.id == context.watch<EmployeesProvider>().selectedEmployee!.id,
                // );
                // if (index >= 0) {
                //   color = kSunColorPri;
                //   shiftStatus = 'Day';
                //   shift = ShiftStatus.day;
                // } else {
                //   int index = dailyShift.nightShiftEmployee.indexWhere(
                //     (value) => value!.id == context.watch<EmployeesProvider>().selectedEmployee!.id,
                //   );
                //   if (index >= 0) {
                //     color = kNightColorPri;
                //     shiftStatus = 'Night';
                //     shift = ShiftStatus.night;
                //   } else {
                //     int index = dailyShift.regularShiftEmployee.indexWhere(
                //       (value) =>
                //           value!.id == context.watch<EmployeesProvider>().selectedEmployee!.id,
                //     );
                //     if (index >= 0) {
                //       color = Colors.green[200]!;
                //       shiftStatus = 'Reg';
                //       shift = ShiftStatus.regular;
                //     } else {
                //       int index = dailyShift.vacationShiftEmployee.indexWhere(
                //         (value) =>
                //             value!.id == context.watch<EmployeesProvider>().selectedEmployee!.id,
                //       );
                //       if (index >= 0) {
                //         color = const Color.fromARGB(255, 177, 120, 243);
                //         shiftStatus = 'Vac';
                //         shift = ShiftStatus.vacation;
                //       } else {
                //         int index = dailyShift.regularShortShiftEmployee.indexWhere(
                //           (value) =>
                //               value!.id == context.watch<EmployeesProvider>().selectedEmployee!.id,
                //         );
                //         if (index >= 0) {
                //           color = kNightColorSL.withOpacity(0.6);
                //           shiftStatus = 'RegShort';
                //           shift = ShiftStatus.regularShort;
                //         } else {
                //           int index = dailyShift.nightInShiftEmployee.indexWhere(
                //             (value) =>
                //                 value!.id ==
                //                 context.watch<EmployeesProvider>().selectedEmployee!.id,
                //           );
                //           if (index >= 0) {
                //             color = kNightColorSL.withOpacity(0.5);
                //             shiftStatus = 'In';
                //             shift = ShiftStatus.nightIn;
                //           } else {
                //             int index = dailyShift.nightOutShiftEmployee.indexWhere(
                //               (value) =>
                //                   value!.id ==
                //                   context.watch<EmployeesProvider>().selectedEmployee!.id,
                //             );
                //             if (index >= 0) {
                //               color = kNightColorSL.withOpacity(0.5);
                //               shiftStatus = 'Out';
                //               shift = ShiftStatus.nightOut;
                //             }
                //           }
                //         }
                //       }
                //     }
                //   }
                // }
                // if (isHoliday) {
                //   if (shift == ShiftStatus.day || shift == ShiftStatus.night) {
                //     shift = ShiftStatus.holidayDay;
                //   } else if (shift == ShiftStatus.nightIn) {
                //     shift = ShiftStatus.holidayIn;
                //   } else if (shift == ShiftStatus.nightOut) {
                //     shift = ShiftStatus.holidayOut;
                //   }
                // }
                // provider.fillShiftCount(result.date.month, shift);
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
                      _buildDateWidget(dailyShift, textColor),
                      _buildShiftStatusText(shiftStatus.toShortStr(), textColor)
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

  Align _buildShiftStatusText(String shiftStatus, Color textColor) {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            shiftStatus,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(color: textColor, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ));
  }

  Align _buildDateWidget(DailyShifts result, Color textColor) {
    return Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 4.0, top: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat.d().format(result.date),
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      fontSize: 20,
                      height: 0.99,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  )),
              Text(
                DateFormat.MMM().format(result.date),
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Expanded _buildDayName(String text, [Color? textColor]) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        decoration: const BoxDecoration(
          color: kSunColorTR,
        ),
        child: Text(
          text,
          style: GoogleFonts.lato(
            color: textColor,
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
        border: Border.all(width: 0.5),
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Icon(
        iconData,
        color: Colors.red,
        size: 16,
      ),
    );
  }
}
