import 'package:flutter/material.dart';
import 'login_screen.dart'; // تأكدي من مسار ملف شاشة الدخول لديكِ

void main() {
  // أزلنا كل سطور Firebase والـ WidgetsFlutterBinding من هنا
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'صمد عالمغمض (نسخة الواجهات)',
      debugShowCheckedModeBanner: false, // لإخفاء شريط Debug المزعج
      theme: ThemeData(
        // إعداد ألوان التطبيق الأساسية
        scaffoldBackgroundColor: const Color(0xFF0D1026),
        primaryColor: const Color(0xFFF7A2C5),
        fontFamily: 'Tajawal', // إذا كنتِ تستخدمين خطاً عربياً
      ),
      home: const LoginScreen(),
    );
  }
}
