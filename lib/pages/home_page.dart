import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shift_schedule/models/shift_model.dart';

import '../models/employee.dart';
import '../provider/employee_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    context.read<EmployeesProvider>().getAllEmployees();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeesProvider>();
    return Scaffold(
      appBar: AppBar(),
      body: provider.employees.isEmpty
          ? const CircularProgressIndicator()
          : Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8),
              child: Column(
                children: [
                  DropdownButton<Employee>(
                    value: provider.selectedEmployee,
                    onChanged: (Employee? newValue) {
                      provider.selectedEmployee = newValue;
                    },
                    items: provider.employees.map((Employee employee) {
                      return DropdownMenuItem<Employee>(
                        value: employee,
                        child: Text('${employee.firstName} ${employee.lastName[0]}.'),
                      );
                    }).toList(),
                  ),
                  const Center(
                    child: Text('Hello World'),
                  ),
                  ElevatedButton(onPressed: () async {}, child: const Text('Press Button')),
                  Padding(
                    padding: const EdgeInsets.only(left: 100),
                    child: Row(
                      children: const <Widget>[
                        Expanded(child: Text('Day 🌞')),
                        Expanded(child: Text('Night 🌒')),
                      ],
                    ),
                  ),
                  Expanded(child: Builder(builder: (context) {
    context.read<EmployeesProvider>().calculateShift();

                    return ListView.builder(
                      itemCount: provider.dailyShiftsList.length,
                      itemBuilder: (context, index) {
                        print(index);
                        return ShiftListItem(dailyShifts: provider.dailyShiftsList[index]);
                      },
                    );
                  }))
                ],
              ),
            ),
    );
  }
}

class ShiftListItem extends StatelessWidget {
  ShiftListItem({
    Key? key,
    required this.dailyShifts,
  }) : super(key: key);
  DailyShifts dailyShifts;
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeesProvider>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            '${DateFormat('MMM').format(dailyShifts.date)}\n${dailyShifts.date.day}',
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color.fromARGB(255, 255, 245, 132),
              ),
              child: Column(
                children:
                    dailyShifts.dayShiftEmployee.map((shift) => Text(shift!.firstName)).toList(),
              )),
        ),
        const SizedBox(
          width: 4,
        ),
        Expanded(
          child: Container(
              height: 80,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color.fromARGB(255, 74, 104, 205)),
              child: Column(
                children:
                    dailyShifts.nightShiftEmployee.map((shift) => Text(shift!.firstName)).toList(),
              )),
        )
      ],
    );
  }
}
