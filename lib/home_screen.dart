import 'package:flutter/material.dart';
import 'record_screen.dart';
import 'budget_screen.dart';
import 'categories_screen.dart';
import 'notifications_screen.dart';
import 'transactions_screen.dart';
import 'reports_screen.dart';
import 'wallet_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _budgets = [];
  int _currentBudgetIndex = 0;

  List<Map<String, dynamic>> _transactions = [];

  List<Map<String, dynamic>> _categories = [
    {
      'name': 'أكل ومشروبات',
      'color': const Color(0xFFF473B9),
      'icon': Icons.restaurant,
    },
    {
      'name': 'مواصلات',
      'color': const Color(0xFF5D9CEC),
      'icon': Icons.directions_car,
    },
    {
      'name': 'تسوق',
      'color': const Color(0xFFAC92EC),
      'icon': Icons.shopping_bag,
    },
    {
      'name': 'فواتير وخدمات',
      'color': const Color(0xFFFFCE54),
      'icon': Icons.receipt_long,
    },
    {
      'name': 'أخرى',
      'color': const Color(0xFF48CFAD),
      'icon': Icons.more_horiz,
    },
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryBg = Color(0xFF0D1026);
    const Color accentPink = Color(0xFFF7A2C5);
    const Color cardColor = Color(0xFF1B1E3F);

    double currentTotalBudget = 0.0;
    double currentSpent = 0.0;
    int daysLeft = 0;

    if (_budgets.isNotEmpty && _currentBudgetIndex < _budgets.length) {
      currentTotalBudget = _budgets[_currentBudgetIndex]['amount'];
      currentSpent = _budgets[_currentBudgetIndex]['spent'];
      DateTime end = _budgets[_currentBudgetIndex]['end'];
      daysLeft = end.difference(DateTime.now()).inDays;
    }

    return Scaffold(
      backgroundColor: primaryBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationsScreen(),
            ),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'مرحبا يا رهيبين',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'نظرة على ميزانيتك',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: accentPink,
              child: Icon(Icons.person, color: Colors.black),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: 280,
              child: PageView.builder(
                itemCount: _budgets.length + 1,
                onPageChanged: (index) {
                  setState(() {
                    _currentBudgetIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  if (index == _budgets.length) {
                    return _buildEmptyBudgetCircle();
                  }
                  return _buildActiveBudgetCircle(_budgets[index]);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_budgets.length + 1, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentBudgetIndex == index ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentBudgetIndex == index
                        ? accentPink
                        : Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard(
                  'إجمالي المصروف',
                  '${currentSpent.toInt()} \$',
                  Icons.account_balance_wallet,
                  cardColor,
                ),
                _buildStatCard(
                  'إجمالي العمليات',
                  '${_transactions.length}',
                  Icons.calendar_month,
                  cardColor,
                ),
                _buildStatCard(
                  'الأيام المتبقية',
                  '$daysLeft',
                  Icons.timer,
                  cardColor,
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'آخر المعاملات',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (_transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30.0),
                child: Center(
                  child: Text(
                    'لا توجد مصاريف حتى الآن.\nاضغط على المايكروفون لإضافة مصروف!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, height: 1.5),
                  ),
                ),
              )
            else
              ..._transactions.reversed.map(
                (tx) => _buildTransactionItem(
                  tx['title'],
                  'اليوم',
                  '- ${tx['amount']} \$',
                  tx['icon'],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: cardColor,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'الرئيسية', accentPink),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TransactionsScreen(),
                  ),
                ),
                child: _buildNavItem(
                  Icons.list_alt,
                  'المعاملات',
                  Colors.white54,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (_budgets.isEmpty ||
                      _currentBudgetIndex == _budgets.length) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'الرجاء التمرير لميزانية صالحة أو إنشاء واحدة!',
                        ),
                      ),
                    );
                    return;
                  }

                  final newExpense = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecordScreen(),
                    ),
                  );

                  if (newExpense != null && newExpense is Map) {
                    setState(() {
                      _transactions.add(newExpense.cast<String, dynamic>());
                      _budgets[_currentBudgetIndex]['spent'] +=
                          newExpense['amount'];
                    });
                  }
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFF7A2C5), Color(0xFF8262A4)],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.mic, color: Colors.white, size: 32),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final updatedCategories = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoriesScreen(
                        transactions: _transactions,
                        categories: _categories,
                      ),
                    ),
                  );
                  if (updatedCategories != null)
                    setState(() => _categories = updatedCategories);
                },
                child: _buildNavItem(Icons.category, 'محفظتي', Colors.white54),
              ),
              // الزر الرابع: المحفظة (بدلاً من التصنيفات)
              GestureDetector(
                onTap: () async {
                  // الانتقال إلى شاشة المحفظة
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WalletScreen(),
                    ),
                  );
                },
                child: _buildNavItem(
                  Icons.account_balance_wallet, // أيقونة المحفظة
                  'المحفظة',
                  Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyBudgetCircle() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BudgetScreen()),
        );
        if (result != null && result is Map) {
          setState(() {
            _budgets.add({
              'name': result['name'],
              'amount': result['amount'],
              'spent': 0.0,
              'start': result['start'],
              'end': result['end'],
            });
            _currentBudgetIndex = _budgets.length - 1;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFF7A2C5).withValues(alpha: 0.5),
            width: 2,
          ),
          color: Colors.white.withValues(alpha: 0.05),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: Color(0xFFF7A2C5), size: 50),
            SizedBox(height: 10),
            Text(
              'إضافة ميزانية جديدة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveBudgetCircle(Map<String, dynamic> budget) {
    double total = budget['amount'];
    double spent = budget['spent'];
    double remaining = total - spent;
    double progress = total > 0 ? (remaining / total) : 0.0;
    int percentage = (progress * 100).toInt();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          budget['name'],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: CircularProgressIndicator(
                value: progress < 0 ? 0 : progress,
                strokeWidth: 15,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress < 0.2 ? Colors.red : const Color(0xFFF7A2C5),
                ),
              ),
            ),
            Column(
              children: [
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'المتبقي',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  '\$ ${remaining.toInt()}',
                  style: TextStyle(
                    color: progress < 0.2
                        ? Colors.red
                        : const Color(0xFFF7A2C5),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'من \$ ${total.toInt()}',
          style: const TextStyle(color: Colors.white54),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 105,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 8),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    String title,
    String date,
    String amount,
    IconData icon,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        date,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      trailing: Text(
        amount,
        style: const TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        Text(label, style: TextStyle(color: color, fontSize: 10)),
      ],
    );
  }
}
