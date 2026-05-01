import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/api_keys.dart';

class AiService {
  static Future<Map<String, dynamic>?> analyzeExpense(String userInput) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: ApiKeys.geminiKey,
      );

      final prompt =
          '''
      أنت مساعد مالي ذكي لتطبيق اسمه "صمد عالمغمض".
      قام المستخدم بإدخال الجملة التالية (قد تكون بالعربية أو بالإنجليزية): "$userInput"
      
      استخرج البيانات التالية:
      1. المبلغ (رقم فقط).
      2. الوصف (كلمة أو كلمتين تعبر عن المصروف، اكتبها بنفس اللغة التي تحدث بها المستخدم).
      3. التصنيف (يجب أن تترجم التصنيف وتختار واحداً من هذه القائمة حرفياً باللغة العربية حصراً: "أكل ومشروبات", "مواصلات", "تسوق", "فواتير وخدمات", "أخرى").
      
      أرجع النتيجة بصيغة JSON فقط بهذا الشكل تماماً وبدون أي نصوص إضافية:
      {"amount": 15.0, "title": "Taxi", "category": "مواصلات"}
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      final String responseText = response.text ?? '';

      String cleanJson = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      return jsonDecode(cleanJson);
    } catch (e) {
      print('حدث خطأ في الذكاء الاصطناعي: $e');
      return null;
    }
  }
}
