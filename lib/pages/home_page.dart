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

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  void openListModal() async {
    final employees = context.read<EmployeesProvider>().employees;

    final result = await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * .5,
          child: Column(
            children: [
              Stack(
                children: <Widget>[
                  Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back))),
                  Container(
                      height: 48,
                      width: double.infinity,
                      child: Center(
                          child: Text(
                        'Select Shift Controller',
                        style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold),
                      ))),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 0.1,
                      child: ListTile(
                        title: Center(
                            child:
                                Text("${employees[index].firstName} ${employees[index].lastName}")),
                        onTap: () {
                          Navigator.pop(context, employees[index]);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      context.read<EmployeesProvider>().selectedEmployee = result;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        'Controller: ${provider.selectedEmployee!.firstName} ${provider.selectedEmployee!.lastName[0]}.',
                        style: GoogleFonts.lato(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      IconButton(
                          onPressed: () {
                            provider.isCalendarView = !provider.isCalendarView;
                          },
                          icon: Icon(provider.isCalendarView
                              ? Icons.view_timeline_outlined
                              : Icons.calendar_month_outlined)),
                      IconButton(onPressed: openListModal, icon: const Icon(Icons.settings))
                    ],
                  )
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


  @override
  bool get wantKeepAlive => true;
}
