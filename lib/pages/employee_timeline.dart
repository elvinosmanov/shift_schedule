import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shift_schedule/enums/positions.dart';
import 'package:shift_schedule/methods/global_methods.dart';
import '../models/employee.dart';
import '../provider/employee_provider.dart';
import '../widgets/custom_date_picker.dart';
import '../widgets/employee_schedule_card.dart';
import '../widgets/schedule_date_widget.dart';

class EmployeeTimeLine extends StatefulWidget {
  const EmployeeTimeLine({
    super.key,
  });

  @override
  State<EmployeeTimeLine> createState() => _EmployeeTimeLineState();
}

class _EmployeeTimeLineState extends State<EmployeeTimeLine> {
  final ScrollController _scrollController = ScrollController();
  ShiftStatus isEmployeeSelected(Map<ShiftStatus, List<Employee>> map) {
    final selectedEmployee = context.watch<EmployeesProvider>().selectedEmployee!;
    if (map[ShiftStatus.day]!.contains(selectedEmployee)) {
      return ShiftStatus.day;
    }
    if (map[ShiftStatus.night]!.contains(selectedEmployee)) {
      return ShiftStatus.night;
    }
    if (map[ShiftStatus.nightIn]!.contains(selectedEmployee)) {
      return ShiftStatus.night;
    }
   
    return ShiftStatus.off;
  }

  @override
  void initState() {
    context.read<EmployeesProvider>().calculateScrollOfsset();
    // WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToIndex(DateTime.now(),context.read<EmployeesProvider>()));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void _scrollToIndex(DateTime selectedDate, EmployeesProvider provider) {
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeesProvider>();
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomDatePicker(
            onDateChange: (selectedDate) => _scrollToIndex(selectedDate, provider),
          ),
          Expanded(
            child: ListView.builder(
              key: const PageStorageKey('myListView'),
              controller: _scrollController,
              itemCount: provider.dailyShiftsList.length,
              itemBuilder: (context, index) {
                final dailyShift = provider.dailyShiftsList[index];
                // bool isHoliday = provider.isHolidayToday(dailyShift.date);
                final selectedControllerStatus = isEmployeeSelected(dailyShift.shiftEmployees);
                
                // int i = dailyShift.dayShiftEmployee.indexWhere(
                //   (value) => value!.id == context.watch<EmployeesProvider>().selectedEmployee!.id,
                // );
                // final nightIn = dailyShift.nightInShiftEmployee.indexWhere(
                //   (value) => value!.id == context.watch<EmployeesProvider>().selectedEmployee!.id,
                // );

                // final night = dailyShift.nightShiftEmployee.indexWhere(
                //   (value) => value!.id == context.watch<EmployeesProvider>().selectedEmployee!.id,
                // );
                // int j = nightIn + night;
                // if (i + j >= -1) {
                //   hasSelectedController = true;
                // }
                return Container(
                  padding: const EdgeInsets.only(bottom: 12.0, top: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ScheduleDateWidget(
                          date: dailyShift.date, status: selectedControllerStatus),
                      EmployeeScheduleCards(
                        isDayShift: true,
                        employees: dailyShift.shiftEmployees[ShiftStatus.day]!,
                      ),
                      const SizedBox(width: 10),
                      EmployeeScheduleCards(
                        isDayShift: false,
                        employees: _combineNights(dailyShift.shiftEmployees),
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

  List<Employee?> _combineNights(Map<ShiftStatus, List<Employee?>> shiftEmployees) {
    final result = [...shiftEmployees[ShiftStatus.night]!, ...shiftEmployees[ShiftStatus.nightIn]!];
    print(result.length);
    return result
      ..sort(
        (a, b) => a!.id.compareTo(b!.id),
      );
  }
}
