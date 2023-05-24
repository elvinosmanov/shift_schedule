import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/employee.dart';

class EmployeeListModal extends StatelessWidget {
  final List<Employee> employees;

  const EmployeeListModal({Key? key, required this.employees}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
              Container(
                height: 48,
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Select Shift Controller',
                    style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                return EmployeeCard(
                  employee: employees[index],
                  onTap: () {
                    Navigator.pop(context, employees[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback onTap;

  const EmployeeCard({Key? key, required this.employee, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.1,
      child: ListTile(
        title: Center(
          child: Text("${employee.firstName} ${employee.lastName}"),
        ),
        onTap: onTap,
      ),
    );
  }
}
