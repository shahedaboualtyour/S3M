// مسار الملف: lib/services/auth_service.dart
// 🌟 ملاحظة: أزلنا مكتبة http تماماً من هنا

class AuthService {
  // محاكاة تسجيل الدخول (Mock Login)
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    // محاكاة تأخير الشبكة (ثانية واحدة) لتبدو العملية حقيقية
    await Future.delayed(const Duration(seconds: 1));

    // في وضع الواجهات (UI Mode)، نعتبر دائماً أن الدخول صحيح
    // إذا أردتِ تجربة خطأ، يمكنك وضع شرط بسيط مثل:
    // if (password != '123456') return {'success': false, 'message': 'كلمة المرور خاطئة'};

    return {'success': true, 'message': ' تم تسجيل الدخول بنجاح'};
  }

  // محاكاة التسجيل (Mock Register)
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String birthday,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return {'success': true, 'message': 'تم تسجيل الدخول بنجاح'};
  }
}
