import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/budget_provider.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ar', null);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => BudgetProvider())],
      child: const SammedApp(),
    ),
  );
}

class SammedApp extends StatelessWidget {
  const SammedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'صمد عالمغمض',
      theme: ThemeData(
        primaryColor: const Color(0xFF1E2147),
        fontFamily: 'Cairo',
      ),
      home: const LoginScreen(),
    );
  }
}
