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
  final controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
                      Text(
                        'Employee: ${provider.selectedEmployee!.firstName} ${provider.selectedEmployee!.lastName[0]}.',
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      if (provider.hasUpdate)
                        IconButton(
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
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
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            provider.isCalendarView = !provider.isCalendarView;
                          },
                          icon: Icon(provider.isCalendarView
                              ? Icons.view_timeline_outlined
                              : Icons.calendar_month_outlined)),
                      IconButton(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          onPressed: openSalaryCalculationModal,
                          icon: const Icon(Icons.attach_money_outlined)),
                      IconButton(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          onPressed: openListModal,
                          icon: const Icon(Icons.person_search)),
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
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Center(
          child: Column(
            children: [
              const SizedBox(height: 6),
              Text(
                'Monthly Salary Calculation',
                style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.only(left: 32, right: 32),
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  maxLines: 1,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter your gross',
                      isCollapsed: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8)),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildShiftCountList(0),
                  if (provider.shiftCount.length >= 2) _buildShiftCountList(1),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShiftCountList(int index) {
    final DateTime month = context.read<EmployeesProvider>().beginningOfMonth;
    final monthInt = month.month;
    final monthlyHour =
        context.read<EmployeesProvider>().monthlyHours[index == 0 ? monthInt - 1 : monthInt];
    final int totalHour = calculateTotalHour(index: index);
    final double calHour = calculatedHour(index: index);
    double finalMoney =
        controller.text.isEmpty ? 0 : double.parse(controller.text) * calHour / (monthlyHour ?? 1);
    final calTax = calculateTax(finalMoney, 0, 200);
    final amountHeld =
        finalMoney * 0.03 + finalMoney * 0.01 + finalMoney * 0.02 + finalMoney * 0.005 + calTax;
    final netSalary = finalMoney - amountHeld;
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: DateFormat.MMMM()
                  .format(index == 0 ? month : month.add(const Duration(days: 31))),
              style:
                  GoogleFonts.lato(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                    text: ' (${monthlyHour}h)',
                    style: GoogleFonts.lato(fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 132,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: ShiftStatus.values.map((e) {
                        return buildShiftStatusText(e, index);
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  buildLabelText('Total hours:'),
                  buildLabelText('Calculated hours:'),
                ],
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 132,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          ShiftStatus.values.map((e) => buildShiftCountText(e, index)).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  buildResultText(totalHour.toString()),
                  buildResultText(calHour.toStringAsFixed(1)),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Expected salary',
                  style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Text(
            netSalary.toStringAsFixed(2),
            style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ],
      ),
    );
  }

  int calculateTotalHour({required index}) {
    return calculateHour(index, 11, 11, 3, 8, 11, 3, 8, 8, 7).toInt();
  }

  double calculatedHour({required index}) {
    return calculateHour(index, 11.6, 15.4, 4.2, 11.2, 22, 6, 16, 8, 7);
  }

  double calculateHour(
      int index,
      double dayRate,
      double nightRate,
      double nightInRate,
      double nightOutRate,
      double holidayDayRate,
      double holidayInRate,
      double holidayOutRate,
      double regularRate,
      double regularShortRate) {
    return (giveCount(ShiftStatus.day, index) ?? 0) * dayRate +
        (giveCount(ShiftStatus.night, index) ?? 0) * nightRate +
        (giveCount(ShiftStatus.nightIn, index) ?? 0) * nightInRate +
        (giveCount(ShiftStatus.nightOut, index) ?? 0) * nightOutRate +
        (giveCount(ShiftStatus.holidayDay, index) ?? 0) * holidayDayRate +
        (giveCount(ShiftStatus.holidayIn, index) ?? 0) * holidayInRate +
        (giveCount(ShiftStatus.holidayOut, index) ?? 0) * holidayOutRate +
        (giveCount(ShiftStatus.regular, index) ?? 0) * regularRate +
        (giveCount(ShiftStatus.regularShort, index) ?? 0) * regularShortRate;
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
    if (provider.shiftCount.length > provider.selectedEmployee!.id - 1 &&
        provider.shiftCount[provider.selectedEmployee!.id - 1].length > index) {
      return provider.shiftCount[provider.selectedEmployee!.id - 1][index][shiftStatus];
    }
    return null;
  }

  Widget buildShiftStatusText(ShiftStatus status, int index) {
    final count = giveCount(status, index);
    return count != null
        ? Text(
            '${status.toStr()}:',
            style: GoogleFonts.lato(fontSize: 15),
          )
        : const SizedBox.shrink();
  }

  Widget buildShiftCountText(ShiftStatus status, int index) {
    final count = giveCount(status, index);
    return count != null
        ? Text(
            '$count',
            style: GoogleFonts.lato(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          )
        : const SizedBox.shrink();
  }

  Text buildLabelText(String text) {
    return Text(
      text,
      style: GoogleFonts.lato(fontSize: 15),
    );
  }

  Text buildResultText(String text) {
    return Text(
      text,
      style: GoogleFonts.lato(
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
