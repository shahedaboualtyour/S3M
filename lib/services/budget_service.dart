import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BudgetService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static Future<Map<String, dynamic>> createBudget({
    required String name,
    required double allocatedAmount,
    required String renewalCycle,
    required String startRenewalDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      if (token == null) {
        return {'success': false, 'message': 'يرجى تسجيل الدخول أولاً'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/budgets'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'name': name,
          'allocated_amount': allocatedAmount.toString(),
          'renewal_cycle': renewalCycle,
          'start_renewal_date': startRenewalDate,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'budget': data['budget'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'فشل في إنشاء الميزانية',
        };
      }
    } catch (e) {
      print('Error: $e');
      return {'success': false, 'message': 'تأكد من اتصالك بالإنترنت'};
    }
  }
}
