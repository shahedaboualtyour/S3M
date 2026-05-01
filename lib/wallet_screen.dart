import 'package:flutter/material.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  // بيانات وهمية مؤقتة (Mock Data) لاحقاً سنربطها بالـ Provider أو API
  final double totalSaved = 600.0;

  final List<Map<String, dynamic>> savingSources = [
    {
      'title': 'من محفظة الطعام',
      'amount': 200,
      'percentage': 33.3,
      'icon': Icons.restaurant,
      'color': const Color(0xFFF7A2C5),
    },
    {
      'title': 'من محفظة السفر',
      'amount': 200,
      'percentage': 33.3,
      'icon': Icons.flight,
      'color': const Color(0xFF5D9CEC),
    },
    {
      'title': 'من محفظة المدرسة',
      'amount': 200,
      'percentage': 33.3,
      'icon': Icons.menu_book,
      'color': const Color(0xFFAC92EC),
    },
    {
      'title': 'من محفظة الرياضة',
      'amount': 150,
      'percentage': 25.0,
      'icon': Icons.fitness_center,
      'color': const Color(0xFFFFCE54),
    },
  ];

  @override
  Widget build(BuildContext context) {
    // الألوان المعتمدة في تطبيقك
    const Color primaryBg = Color(0xFF0D1026);
    const Color cardColor = Color(0xFF1B1E3F);
    const Color accentPink = Color(0xFFF7A2C5);

    return Scaffold(
      backgroundColor: primaryBg,

      // 1. الشريط العلوي (AppBar)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {},
          ),
        ],
        title: const Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'المحفظة',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.account_balance_wallet, color: accentPink, size: 20),
              ],
            ),
            Text(
              'تخزين الفائض من ميزانياتك',
              style: TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],
        ),
      ),

      // 2. جسم الشاشة
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 3. البطاقة العلوية (إجمالي المبلغ المجمد)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // الأيقونة أو الرسمة (استخدمنا أيقونة خزنة كبديل سريع للصورة)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2D5C),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: accentPink,
                      size: 40,
                    ),
                  ),

                  // النصوص والرصيد
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'إجمالي المحفظة',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${totalSaved.toInt()} \$',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Text(
                            'المبلغ المجمد',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Icon(
                            Icons.ac_unit,
                            color: Colors.cyan.shade300,
                            size: 14,
                          ), // أيقونة تعبر عن التجميد
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 4. عنوان قسم "مصادر الإيداع"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'مصادر الإيداع في المحفظة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: const Color(0xFF2A2D5C),
                  child: const Icon(
                    Icons.arrow_downward,
                    color: accentPink,
                    size: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // 5. قائمة المصادر (ListView)
            // نستخدم ListView.builder لأنها الأفضل في الأداء (Best Practice) لو كان لدينا عناصر كثيرة
            ListView.builder(
              shrinkWrap:
                  true, // ضروري عندما نضع ListView داخل SingleChildScrollView
              physics:
                  const NeverScrollableScrollPhysics(), // نمنع التمرير الداخلي لأن الشاشة كلها تمرر
              itemCount: savingSources.length,
              itemBuilder: (context, index) {
                final source = savingSources[index];
                return _buildSourceCard(
                  title: source['title'],
                  amount: source['amount'],
                  percentage: source['percentage'],
                  icon: source['icon'],
                  color: source['color'],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 🌟 أفضل ممارسة (Best Practice): استخراج واجهات الـ UI المكررة إلى دوال منفصلة 🌟
  Widget _buildSourceCard({
    required String title,
    required int amount,
    required double percentage,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1E3F), // لون البطاقة
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // الأيقونة بخلفية ملونة شفافة
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),

          // النصوص الوسطى (الاسم والنسبة)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      '$amount \$',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      ' • من إجمالي المحفظة ',
                      style: TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // المبلغ بالموجب على اليسار
          Text(
            '+ $amount \$',
            style: const TextStyle(
              color: Color(0xFF48CFAD),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
