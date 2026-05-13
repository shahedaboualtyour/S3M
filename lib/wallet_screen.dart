import 'package:flutter/material.dart';
import 'record_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late double _totalSaved;
  late List<Map<String, dynamic>> _savingSources;

  @override
  void initState() {
    super.initState();
    // 🌟 تحديث البيانات لتتطابق منطقياً مع ما يوجد في الشاشة الرئيسية 🌟
    // الشاشة الرئيسية تعرض مصاريف (15, 100, 250).
    // هنا سنفترض أننا وفرنا مبالغ أخرى من نفس التصنيفات لنضعها في المحفظة.

    _totalSaved = 365.0; // مجموع التوفير الوهمي المتطابق

    _savingSources = [
      {
        'title': 'وفر من قهوة الصباح',
        'amount': 15,
        'percentage': (15 / 365) * 100,
        'icon': Icons.local_cafe,
        'color': const Color(0xFFF7A2C5),
      },
      {
        'title': 'وفر من بنزين السيارة',
        'amount': 100,
        'percentage': (100 / 365) * 100,
        'icon': Icons.directions_car,
        'color': const Color(0xFF5D9CEC),
      },
      {
        'title': 'وفر من سوبر ماركت',
        'amount': 250,
        'percentage': (250 / 365) * 100,
        'icon': Icons.shopping_cart,
        'color': const Color(0xFFAC92EC),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBg = Color(0xFF0D1026);
    const Color cardColor = Color(0xFF1B1E3F);
    const Color accentPink = Color(0xFFF7A2C5);

    return Scaffold(
      backgroundColor: primaryBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: accentPink),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('سيتم تفعيل الإضافة اليدوية قريباً'),
                ),
              );
            },
          ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'إجمالي المحفظة',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${_totalSaved.toInt()} \$',
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
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

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

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _savingSources.length,
              itemBuilder: (context, index) {
                final source = _savingSources[index];
                return _buildSourceCard(
                  title: source['title'],
                  amount: source['amount'],
                  percentage: source['percentage'],
                  icon: source['icon'],
                  color: source['color'],
                );
              },
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

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
        color: const Color(0xFF1B1E3F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
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
                      '  •  من إجمالي المحفظة ',
                      style: TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%', // تنسيق النسبة لمنزلة عشرية واحدة
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

  Widget _buildBottomNav(BuildContext context) {
    return BottomAppBar(
      color: const Color(0xFF1B1E3F),
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: _buildNavItem(Icons.home, 'الرئيسية', Colors.white54),
            ),
            _buildNavItem(Icons.list_alt, 'المعاملات', Colors.white54),

            GestureDetector(
              onTap: () async {
                final returnedData = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RecordScreen()),
                );

                if (returnedData != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تسجيل المعاملة بنجاح!'),
                      backgroundColor: Colors.green,
                    ),
                  );
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

            _buildNavItem(Icons.category, 'التصنيفات', Colors.white54),
            _buildNavItem(
              Icons.account_balance_wallet,
              'المحفظة',
              const Color(0xFFF7A2C5),
            ),
          ],
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
