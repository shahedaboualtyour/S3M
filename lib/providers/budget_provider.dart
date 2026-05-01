import 'package:flutter/material.dart';

class BudgetProvider extends ChangeNotifier {
  double _totalBudget = 0.0;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  List<Map<String, dynamic>> _transactions = [];

  List<Map<String, dynamic>> _notifications = [];

  bool _hasAlerted70 = false;

  List<Map<String, dynamic>> _categories = [
    {
      'name': 'أكل ومشروبات',
      'color': const Color(0xFFF473B9),
      'icon': Icons.restaurant,
      'amount': 0.0,
      'percent': 0.0,
    },
    {
      'name': 'مواصلات',
      'color': const Color(0xFF5D9CEC),
      'icon': Icons.directions_car,
      'amount': 0.0,
      'percent': 0.0,
    },
    {
      'name': 'تسوق',
      'color': const Color(0xFFAC92EC),
      'icon': Icons.shopping_bag,
      'amount': 0.0,
      'percent': 0.0,
    },
    {
      'name': 'فواتير وخدمات',
      'color': const Color(0xFFFFCE54),
      'icon': Icons.receipt_long,
      'amount': 0.0,
      'percent': 0.0,
    },
    {
      'name': 'أخرى',
      'color': const Color(0xFF48CFAD),
      'icon': Icons.more_horiz,
      'amount': 0.0,
      'percent': 0.0,
    },
  ];

  double get totalBudget => _totalBudget;
  bool get isBudgetSet => _totalBudget > 0;
  List<Map<String, dynamic>> get transactions => _transactions;
  List<Map<String, dynamic>> get categories => _categories;
  List<Map<String, dynamic>> get notifications => _notifications;

  double get totalSpent {
    return _transactions.fold(0.0, (sum, item) => sum + item['amount']);
  }

  void setBudget(double amount, DateTime start, DateTime end) {
    _totalBudget = amount;
    _startDate = start;
    _endDate = end;
    _hasAlerted70 = false;

    _addNotification(
      title: 'تم إعداد ميزانيتك بنجاح!',
      subtitle:
          'ميزانيتك لهذا الشهر هي ${amount.toInt()}\$. نتمنى لك توفيراً سعيداً.',
      type: 'tip',
      color: const Color(0xFF60C689),
      icon: Icons.check_circle,
      details:
          'لقد قمت بتحديد ميزانيتك بنجاح للفترة من ${start.day}/${start.month} إلى ${end.day}/${end.month}. سنقوم بتنبيهك بمجرد اقترابك من الحد الأقصى.',
    );
    notifyListeners();
  }

  void addTransaction(
    String title,
    double amount,
    String categoryName,
    IconData icon,
  ) {
    _transactions.insert(0, {
      'title': title,
      'amount': amount,
      'category': categoryName,
      'icon': icon,
      'date': DateTime.now(),
    });

    _updateCategoriesData();

    _addNotification(
      title: 'تمت إضافة مصروف جديد',
      subtitle: '$title بقيمة ${amount.toInt()}\$',
      type: 'info',
      color: const Color(0xFFAC92EC),
      icon: icon,
      details:
          'تم خصم مبلغ ${amount.toInt()}\$ من ميزانيتك لشراء "$title" ضمن فئة "$categoryName". الرصيد المتبقي يتحدث تلقائياً.',
    );

    _checkBudgetAlerts();

    notifyListeners();
  }

  void _checkBudgetAlerts() {
    if (_totalBudget == 0) return;
    double progress = totalSpent / _totalBudget;

    if (progress >= 0.70 && !_hasAlerted70) {
      _hasAlerted70 = true; // لكي لا يزعج المستخدم ويتكرر
      _addNotification(
        title: 'تنبيه: وصلت إلى 70% من ميزانيتك',
        subtitle: 'لقد أنفقت ${totalSpent.toInt()}\$ من ميزانيتك.',
        type: 'alert',
        color: const Color(0xFFF473B9),
        icon: Icons.warning_amber_rounded,
        details:
            'الرجاء الانتباه! لقد تجاوزت 70% من ميزانيتك المحددة لهذا الشهر. حاول تقليل مصاريفك في الأيام القادمة، خاصة في فئة "${_categories.first['name']}" لأنها تستهلك الجزء الأكبر.',
      );
    }
  }

  void _addNotification({
    required String title,
    required String subtitle,
    required String type,
    required Color color,
    required IconData icon,
    required String details,
  }) {
    _notifications.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'subtitle': subtitle,
      'type': type, // 'alert', 'tip', 'info'
      'color': color,
      'icon': icon,
      'time': DateTime.now(),
      'details': details,
      'isRead': false,
    });
  }

  void markNotificationAsRead(String id) {
    var index = _notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
      notifyListeners();
    }
  }

  void _updateCategoriesData() {
    double spent = totalSpent;
    for (var cat in _categories) {
      double catTotal = _transactions
          .where((tx) => tx['category'] == cat['name'])
          .fold(0.0, (sum, tx) => sum + tx['amount']);
      cat['amount'] = catTotal;
      cat['percent'] = spent > 0 ? (catTotal / spent) : 0.0;
    }
    _categories.sort((a, b) => b['amount'].compareTo(a['amount']));
  }
}
