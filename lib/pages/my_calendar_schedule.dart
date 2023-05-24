import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shift_schedule/enums/positions.dart';

import 'package:shift_schedule/methods/global_methods.dart';
import 'package:shift_schedule/models/shift_model.dart';
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
                final result = provider.dailyShiftsList[gridIndex - startWeekday];
                bool isHoliday = provider.isHolidayToday(result.date);
                final isToday = GlobalMethods.isSameDate(DateTime.now(), result.date);
                Color color = Colors.grey[100]!;
                String shiftStatus = 'Off';
                var shift = ShiftStatus.off;

                final Color textColor = shiftStatus == 'Night' ? Colors.white : Colors.black;

                int index = result.dayShiftEmployee.indexWhere(
                  (value) => value!.id == context.watch<EmployeesProvider>().selectedEmployee!.id,
                );
                if (index >= 0) {
                  color = kSunColorPri;
                  shiftStatus = 'Day';
                  shift = ShiftStatus.day;
                } else {
                  int index = result.nightShiftEmployee.indexWhere(
                    (value) => value!.id == context.watch<EmployeesProvider>().selectedEmployee!.id,
                  );
                  if (index >= 0) {
                    color = kNightColorPri;
                    shiftStatus = 'Night';
                    shift = ShiftStatus.night;
                  } else {
                    int index = result.regularShiftEmployee.indexWhere(
                      (value) =>
                          value!.id == context.watch<EmployeesProvider>().selectedEmployee!.id,
                    );
                    if (index >= 0) {
                      color = Colors.green[200]!;
                      shiftStatus = 'Reg';
                      shift = ShiftStatus.regular;
                    } else {
                      int index = result.vacationShiftEmployee.indexWhere(
                        (value) =>
                            value!.id == context.watch<EmployeesProvider>().selectedEmployee!.id,
                      );
                      if (index >= 0) {
                        color = kNightColorSL;
                        shiftStatus = 'Vac';
                        shift = ShiftStatus.vacation;
                      } else {
                        int index = result.regularShortShiftEmployee.indexWhere(
                          (value) =>
                              value!.id == context.watch<EmployeesProvider>().selectedEmployee!.id,
                        );
                        if (index >= 0) {
                          color = kNightColorSL.withOpacity(0.6);
                          shiftStatus = 'RegShort';
                          shift = ShiftStatus.regularShort;
                        } else {
                          int index = result.nightInShiftEmployee.indexWhere(
                            (value) =>
                                value!.id ==
                                context.watch<EmployeesProvider>().selectedEmployee!.id,
                          );
                          if (index >= 0) {
                            color = kNightColorSL.withOpacity(0.5);
                            shiftStatus = 'In';
                            shift = ShiftStatus.nightIn;
                          } else {
                            int index = result.nightOutShiftEmployee.indexWhere(
                              (value) =>
                                  value!.id ==
                                  context.watch<EmployeesProvider>().selectedEmployee!.id,
                            );
                            if (index >= 0) {
                              color = kNightColorSL.withOpacity(0.5);
                              shiftStatus = 'Out';
                              shift = ShiftStatus.nightOut;
                            }
                          }
                        }
                      }
                    }
                  }
                }
                if (isHoliday) {
                  if (shift == ShiftStatus.day || shift == ShiftStatus.night) {
                    shift = ShiftStatus.holidayDay;
                  } else if (shift == ShiftStatus.nightIn) {
                    shift = ShiftStatus.holidayIn;
                  } else if (shift == ShiftStatus.nightOut) {
                    shift = ShiftStatus.holidayOut;
                  }
                }
                if (provider.beginningOfMonth.month == result.date.month) {
                  provider.shiftCount.add({});
                  provider.shiftCount[0].update(
                    shift.toString(),
                    (value) => value + 1,
                    ifAbsent: () => 1,
                  );
                } else {
                  provider.shiftCount.add({});
                  provider.shiftCount[1].update(
                    shift.toString(),
                    (value) => value + 1,
                    ifAbsent: () => 1,
                  );
                }
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
                      _buildDateWidget(result, textColor),
                      _buildShiftStatusText(shiftStatus, textColor)
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
