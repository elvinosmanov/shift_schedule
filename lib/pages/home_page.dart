import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shift_schedule/pages/my_calendar_schedule.dart';

import '../provider/employee_provider.dart';
import '../ui/themes.dart';
import '../widgets/loading_employee.dart';
import 'employee_timeline.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    context.read<EmployeesProvider>().getAllEmployees();
    context.read<EmployeesProvider>().getHolidays();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeesProvider>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
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
                    ],
                  ),
                  ElevatedButton.icon(
                      onPressed: () {
                        provider.isCalendarView = !provider.isCalendarView;
                        print(provider.isCalendarView);
                      },
                      icon: Icon(
                        !provider.isCalendarView
                            ? Icons.calendar_today
                            : Icons.view_timeline_outlined,
                        size: 16,
                      ),
                      label: Text(
                        !provider.isCalendarView ? 'Calendar view' : "Timeline view",
                        style: GoogleFonts.lato(fontSize: 12),
                      )),
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: provider.dailyShiftsList.isEmpty
                    ? const LoadingEmployee()
                    : Container(
                        child: provider.isCalendarView
                            ? const MyCalendarSchedule()
                            : const EmployeeTimeLine(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSchedule(EmployeesProvider provider) {
    return const EmployeeTimeLine();
  }
}
