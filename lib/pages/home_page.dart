import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shift_schedule/pages/my_calendar_schedule.dart';

import '../provider/employee_provider.dart';
import '../ui/themes.dart';
import '../widgets/employee_list_modal.dart';
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
                      if (provider.hasUpdate)
                        IconButton(
                            onPressed: 
                            
                            provider.uploadLoading
                                ? null
                                : provider.updateDatabase,
                            icon: provider.uploadLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1,
                                      color: kNightColorPri,
                                    ),
                                  )
                                : const Icon(
                                    Icons.cloud_upload,
                                    color: Colors.red,
                                  )),
                      IconButton(
                          onPressed: () {
                            provider.isCalendarView = !provider.isCalendarView;
                          },
                          icon: Icon(provider.isCalendarView
                              ? Icons.view_timeline_outlined
                              : Icons.calendar_month_outlined)),
                      IconButton(onPressed: openListModal, icon: const Icon(Icons.settings)),
                      IconButton(onPressed: openSalaryCalculationModal, icon: const Icon(Icons.attach_money_outlined))
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
  void openListModal() async {
  final employees = context.read<EmployeesProvider>().employees;

  final result = await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) {
      return EmployeeListModal(employees: employees);
    },
  );

  if (result != null) {
    context.read<EmployeesProvider>().selectedEmployee = result;
  }
}

void openSalaryCalculationModal() async {
  final monthlyHours = context.read<EmployeesProvider>().monthlyHours;
  

  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) {
      return const Text('Montly Salary Calculation');
    },
  );

}
}
