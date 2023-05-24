import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shift_schedule/enums/positions.dart';
import 'package:shift_schedule/extensions/shift_status_extension.dart';
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
                      // const SizedBox(
                      //   height: 4,
                      // ),
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
                            onPressed: provider.uploadLoading ? null : provider.updateDatabase,
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
                      IconButton(
                          onPressed: openSalaryCalculationModal,
                          icon: const Icon(Icons.attach_money_outlined))
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
                        child: !provider.isCalendarView
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
    context.read<EmployeesProvider>().shiftCount = [{}, {}];
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
    final provider = context.read<EmployeesProvider>();
    print(provider.shiftCount.length);
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Center(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                'Monthly Salary Calculation',
                style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildShiftCountList(0),
                  if (provider.shiftCount.length > 31) _buildShiftCountList(1),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Column _buildShiftCountList(int index) {
    final DateTime month = context.read<EmployeesProvider>().beginningOfMonth;
    final monthInt = month.month;
    final monthlyHours = context.read<EmployeesProvider>().monthlyHours;
    final int totalHour = calculateTotalHour(index: index);
    final double calHour = calculatedHour(index: index);
    final finalMoney = 1100 * calHour / totalHour;
    final calTax = calculateTax(finalMoney, 0, 200);
    final amountHeld =
        finalMoney * 0.03 + finalMoney * 0.01 + finalMoney * 0.02 + finalMoney * 0.005 + calTax;
    final netSalary = finalMoney - amountHeld;
    return Column(
      children: [
        Text(DateFormat.MMMM().format(index == 0 ? month : month.add(const Duration(days: 31))),
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: ShiftStatus.values.map((e) {
                    return giveCount(e, index) != null
                        ? Text(
                            '${e.toStr()}:',
                            style: GoogleFonts.lato(fontSize: 15),
                          )
                        : const SizedBox.shrink();
                  }).toList(),
                ),
                // const SizedBox(height: 12),
                Text(
                  'Monthly hours:',
                  style: GoogleFonts.lato(fontSize: 15),
                ),
                Text(
                  'Total hours:',
                  style: GoogleFonts.lato(fontSize: 15),
                ),
              ],
            ),
            // const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: ShiftStatus.values.map((e) {
                    return giveCount(e, index) != null
                        ? Text(
                            '${giveCount(e, index)}',
                            style: GoogleFonts.lato(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const SizedBox.shrink();
                  }).toList(),
                ),
                // const SizedBox(height: 12),
                Text(
                  '${monthlyHours[index == 0 ? monthInt - 1 : monthInt]}',
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$totalHour',
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 24),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Expected salary',
                style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Text(
          '${netSalary.toStringAsFixed(2)}',
          style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  int calculateTotalHour({required index}) {
    int result = (giveCount(ShiftStatus.day, index) ?? 0) * 11 +
        (giveCount(ShiftStatus.night, index) ?? 0) * 11 +
        (giveCount(ShiftStatus.nightIn, index) ?? 0) * 3 +
        (giveCount(ShiftStatus.nightOut, index) ?? 0) * 8 +
        (giveCount(ShiftStatus.holidayDay, index) ?? 0) * 11 +
        (giveCount(ShiftStatus.holidayIn, index) ?? 0) * 3 +
        (giveCount(ShiftStatus.holidayOut, index) ?? 0) * 8 +
        (giveCount(ShiftStatus.regular, index) ?? 0) * 8 +
        (giveCount(ShiftStatus.regularShort, index) ?? 0) * 7;

    return result;
  }

  double calculatedHour({required index}) {
    double result = (giveCount(ShiftStatus.day, index) ?? 0) * 11.6 +
        (giveCount(ShiftStatus.night, index) ?? 0) * 15.4 +
        (giveCount(ShiftStatus.nightIn, index) ?? 0) * 3 * 1.4 +
        (giveCount(ShiftStatus.nightOut, index) ?? 0) * 8 * 1.4 +
        (giveCount(ShiftStatus.holidayDay, index) ?? 0) * 11 * 2 +
        (giveCount(ShiftStatus.holidayIn, index) ?? 0) * 3 * 2 +
        (giveCount(ShiftStatus.holidayOut, index) ?? 0) * 8 * 2 +
        (giveCount(ShiftStatus.regular, index) ?? 0) * 8 +
        (giveCount(ShiftStatus.regularShort, index) ?? 0) * 7;

    return result;
  }

  double calculateTax(double f4, double h4, double a8) {
    if (f4 > 0) {
      if (f4 + h4 > 2500) {
        if (h4 > a8) {
          return (f4 + h4 - 2500) * 0.25 + 2500 * 0.14 - (h4 - a8) * 0.14;
        } else {
          return (f4 + h4 - 2500) * 0.25 + 2500 * 0.14;
        }
      } else {
        if (h4 > a8) {
          return f4 * 0.14;
        } else if (f4 + h4 > a8) {
          return (f4 + h4 - a8) * 0.14;
        } else {
          return 0;
        }
      }
    } else if (f4 > 2500) {
      return (f4 - 2500) * 0.25 + 2500 * 0.14;
    } else if (f4 > a8) {
      return (f4 - a8) * 0.14;
    } else {
      return 0;
    }
  }

  int? giveCount(ShiftStatus shiftStatus, int index) {
    final provider = context.read<EmployeesProvider>();
    return provider.shiftCount[index][shiftStatus.toString()];
  }
}
