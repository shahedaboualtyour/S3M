import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CategoryService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static Future<Map<String, dynamic>> createCategory(
    String name,
    String icon,
    String color,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      if (token == null) {
        return {
          'success': false,
          'message': 'غير مصرح لك، يرجى تسجيل الدخول أولاً',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/categories'),
        headers: {
          'Accept': 'application/json',

          'Authorization': 'Bearer $token',
        },
        body: {'name': name, 'icon': icon, 'color': color},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'category': data['category'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'حدث خطأ أثناء إضافة التصنيف',
        };
      }
    } catch (e) {
      print('خطأ في الاتصال: $e');
      return {'success': false, 'message': 'تأكد من اتصالك بالإنترنت'};
    }
  }
}
