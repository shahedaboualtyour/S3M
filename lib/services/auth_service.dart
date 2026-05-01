import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// 🌟 1. استيراد خدمة الإشعارات لجلب التوكن 🌟
import 'notification_service.dart';

class AuthService {
  // 💡 ملاحظة هندسية: تذكري تغيير 127.0.0.1 إلى 10.0.2.2 إذا كنتِ تختبرين على محاكي أندرويد (Emulator)
  // static const String baseUrl = 'http://127.0.0.1:8000/api';
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      // 🌟 2. جلب الـ FCM Token ونوع الجهاز قبل إرسال الطلب للخادم 🌟
      // String? fcmToken = await NotificationService.initializeAndGetToken();
      // String deviceType = NotificationService.getDeviceType();

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        body: {
          'email': email,
          'password': password,
          // 🌟 3. إضافة البيانات الجديدة التي طلبها فريق الباك إند 🌟
          // 'fcm_token':
          // fcmToken ??
          // '', // نرسله فارغاً إذا لم يوافق المستخدم على الإشعارات
          // 'device_type': deviceType, // سيرسل 'android' أو 'ios' تلقائياً
        },
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final String token = data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        return {
          'success': true,
          'message': data['message'] ?? 'تم تسجيل الدخول بنجاح',
          // ignore: avoid_print
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'فشل تسجيل الدخول',
        };
      }
    } catch (e) {
      print('خطأ في الاتصال (Login): $e');

      return {
        'success': false,
        'message': 'لا يمكن الاتصال بالخادم، تأكد من اتصالك بالإنترنت',
      };
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String birthday,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'birthday': birthday,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': 'تم إنشاء الحساب بنجاح! يمكنك الآن تسجيل الدخول.',
        };
      } else if (response.statusCode == 422) {
        final errorData = jsonDecode(response.body);

        return {
          'success': false,
          'message': errorData['message'] ?? 'البيانات المدخلة غير صالحة',
        };
      } else {
        return {'success': false, 'message': 'حدث خطأ غير متوقع في الخادم'};
      }
    } catch (e) {
      print('خطأ في الاتصال (Register): $e');
      return {'success': false, 'message': 'تأكد من اتصالك بالإنترنت'};
    }
  }
}
