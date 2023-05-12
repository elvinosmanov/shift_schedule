import 'dart:math';

import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:shift_schedule/ui/themes.dart';

import '../provider/employee_provider.dart';
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeesProvider>();
    return Scaffold(
      // appBar: AppBar(),
      body: SafeArea(
        child: Container(
          child:
              provider.dailyShiftsList.isEmpty ? const LoadingEmployee() : buildSchedule(provider),
        ),
      ),
    );
  }

  Widget buildSchedule(EmployeesProvider provider) {
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
          _buildDatePicker(),
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

  DatePicker _buildDatePicker() {
    return DatePicker(
      DateTime.now(),
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
      onDateChange: (selectedDate) {
        final list = _findHeightOfWidgets(selectedDate);
        _scrollToIndex(list[0], list[1]);
        // _selectedDate = selectedDate;
      },
    );
  }

  List<int> _findHeightOfWidgets(DateTime dateTime) {
    int index = 0;
    int count = 0;
    final shiftList = context.read<EmployeesProvider>().dailyShiftsList;
    while (shiftList[index].date.isBefore(dateTime)) {
      final dailyShift = shiftList[index];
      int maxLength = max(
        dailyShift.dayShiftEmployee.length,
        dailyShift.nightShiftEmployee.length,
      );
      count += maxLength;
      if (shiftList.length > index + 1) {
        index++;
      } else {
        break;
      }
    }
    return [index, count];
  }

  void _scrollToIndex(int index, int count) {
    _scrollController.animateTo(
      index * 54 + count * 36,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }
}
