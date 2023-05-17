import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shift_schedule/methods/global_methods.dart';

import 'package:shift_schedule/ui/themes.dart';

import '../provider/employee_provider.dart';
import '../widgets/custom_date_picker.dart';
import '../widgets/employee_schedule_card.dart';
import '../widgets/loading_employee.dart';
import '../widgets/schedule_date_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    context.read<EmployeesProvider>().getAllEmployees();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeesProvider>();
    //TODO: should be uncomment after
    // WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToIndex(DateTime.now()));
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: provider.dailyShiftsList.isEmpty
              ? const LoadingEmployee()
              : const MyCalendarSchedule(),
        ),
      ),
    );
  }

  Widget buildSchedule(EmployeesProvider provider) {
    context.read<EmployeesProvider>().calculateScrollOfsset();

    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            DateFormat.yMMMMd().format(DateTime.now()),
            style: subHeadingStyle,
          ),
          Text(
            'Today',
            style: headingStyle,
          ),
          CustomDatePicker(
            onDateChange: _scrollToIndex,
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: provider.dailyShiftsList.length,
              itemBuilder: (context, index) {
                final dailyShift = provider.dailyShiftsList[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0, top: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ScheduleDateWidget(date: dailyShift.date),
                      EmployeeScheduleCards(
                        isDayShift: true,
                        employees: dailyShift.dayShiftEmployee,
                      ),
                      const SizedBox(width: 10),
                      EmployeeScheduleCards(
                        isDayShift: false,
                        employees: dailyShift.nightShiftEmployee,
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  void _scrollToIndex(DateTime selectedDate) {
    final provider = context.read<EmployeesProvider>();
    int index = provider.dailyShiftsList.indexWhere(
      (element) => GlobalMethods.isSameDate(
        selectedDate,
        element.date,
      ),
    );
    if (index < 0) return;
    _scrollController.animateTo(
      provider.scrollOffsets[index - 1],
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }
}

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
    return Column(
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
        Expanded(
          child: GridView.builder(
            itemCount: provider.dailyShiftsList.length + startWeekday,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, // Number of columns in the grid
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
              childAspectRatio: 0.6,
            ),
            itemBuilder: (context, gridIndex) {
              if (startWeekday > gridIndex) {
                return Container();
              }
              final result = provider.dailyShiftsList[gridIndex - startWeekday];

              Color color = kNightColorTR;
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
                  shiftStatus = 'Ngt';
                }
              }

              return Container(
                decoration: BoxDecoration(
                  color: color,
                ),
                child: Stack(
                  children: <Widget>[
                    Center(
                        child: Text(DateFormat.d().format(result.date),
                            style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ))),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            shiftStatus,
                            style: GoogleFonts.lato(
                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ))
                  ],
                ),
              );
            },
          ),
        ),
      ],
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
