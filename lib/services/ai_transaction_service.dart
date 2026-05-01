import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AiTransactionService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static Future<Map<String, dynamic>> parseVoiceText(String spokenText) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      if (token == null) {
        return {'success': false, 'message': 'يرجى تسجيل الدخول أولاً'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/parse-transaction'),
        headers: {
          'Accept': 'application/json',

          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },

        body: jsonEncode({'text': spokenText}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {'success': true, 'transactions': data['transactions']};
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'فشل في تحليل النص',
        };
      }
    } catch (e) {
      print('Error parsing text: $e');
      return {'success': false, 'message': 'تأكد من اتصالك بالإنترنت'};
    }
  }
}
