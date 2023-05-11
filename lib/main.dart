import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shift_schedule/pages/home_page.dart';
import 'package:shift_schedule/provider/employee_provider.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return  ChangeNotifierProvider(
      create: (context) => EmployeesProvider(),
      child: const MaterialApp(
        title: 'My App',
        home: HomePage(),
      ),
    );
  }
}

