import 'dart:io';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// 🌟 ملاحظة هندسية: دالة معالجة إشعارات الخلفية يجب أن تكون خارج الكلاس 🌟
// لأنها تعمل في Isolate منفصل عندما يكون التطبيق مغلقاً تماماً.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("🔔 إشعار وصل والتطبيق مغلق: ${message.messageId}");
  // هنا يمكنك إضافة منطق لتخزين الإشعار محلياً إذا أردتِ
}

class NotificationService {
  // تذكري تغيير الرابط لـ 10.0.2.2 إذا كنتِ تستخدمين محاكي أندرويد
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // ========================================================
  // 1. تهيئة الإشعارات (تُستدعى في ملف main.dart)
  // ========================================================
  static Future<void> initialize() async {
    // تسجيل معالج الخلفية
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // أ. التعامل مع الإشعارات والتطبيق مفتوح (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 وصل إشعار جديد (التطبيق مفتوح):');
      print('العنوان: ${message.notification?.title}');
      print('المحتوى: ${message.notification?.body}');

      // 💡 مستقبلاً: يمكنك هنا إظهار SnackBar مخصص داخل التطبيق
    });

    // ب. التعامل مع الضغط على الإشعار والتطبيق في الخلفية (Background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('👆 تم الضغط على الإشعار لفتح التطبيق!');
      // يمكنك هنا توجيه المستخدم لشاشة معينة بناءً على message.data
    });

    // ج. التعامل مع فتح التطبيق من إشعار كان موجوداً وهو مغلق تماماً (Terminated)
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print('🚀 تم تشغيل التطبيق من إشعار وهو مغلق تماماً');
    }
  }

  // ========================================================
  // 2. جلب الـ FCM Token وطلب الصلاحيات
  // ========================================================
  static Future<String?> initializeAndGetToken() async {
    try {
      // طلب صلاحيات الإشعارات (ضروري لـ iOS وأندرويد 13+)
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await _messaging.getToken();
        print('🔥 FCM Token المستخرج: $token');

        _listenToTokenRefresh();
        return token;
      } else {
        print('❌ تم رفض صلاحية الإشعارات من قبل المستخدم');
        return null;
      }
    } catch (e) {
      print('خطأ في جلب توكن FCM: $e');
      return null;
    }
  }

  // الاستماع لتحديث التوكن تلقائياً
  static void _listenToTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) {
      print('🔄 تم تحديث التوكن تلقائياً: $newToken');
      // 💡 هندسياً: هنا يجب إرسال التوكن الجديد للـ Backend فوراً
    });
  }

  // ========================================================
  // 3. جلب قائمة الإشعارات السابقة من الخادم (GET with Body)
  // ========================================================
  static Future<Map<String, dynamic>> fetchNotifications() async {
    try {
      // أ. جلب توكن المصادقة (Auth Token) لمعرفة من هو المستخدم
      final prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('auth_token');

      if (authToken == null) {
        return {'success': false, 'message': 'يرجى تسجيل الدخول أولاً'};
      }

      // ب. جلب توكن الإشعارات الحالي ونوع الجهاز
      String? fcmToken = await initializeAndGetToken();
      String deviceType = getDeviceType();

      // ج. الحيلة الهندسية لعمل طلب GET مع Body (كما يطلب الباك إند لديكِ)
      var request = http.Request('GET', Uri.parse('$baseUrl/notifications'));

      request.headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      });

      request.body = jsonEncode({
        "fcm_token": fcmToken ?? "",
        "device_type": deviceType,
      });

      // إرسال الطلب واستلام الرد
      http.StreamedResponse streamedResponse = await request.send();
      var responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        var decodedData = jsonDecode(responseBody);
        return {
          'success': true,
          'notifications':
              decodedData, // قد تكون قائمة List أو Map حسب رد الباك إند
        };
      } else {
        return {'success': false, 'message': 'فشل جلب الإشعارات من الخادم'};
      }
    } catch (e) {
      print('خطأ في الاتصال بجلب الإشعارات: $e');
      return {'success': false, 'message': 'تأكد من اتصالك بالإنترنت'};
    }
  }

  // دالة مساعدة لمعرفة نوع الجهاز
  static String getDeviceType() {
    return Platform.isIOS ? 'ios' : 'android';
  }
}
