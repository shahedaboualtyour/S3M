import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/budget_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedPeriodIndex = 1;
  DateTime _currentDate = DateTime.now();

  final List<String> _periods = ['أسبوعي', 'شهري', 'سنوي'];

  void _changeDate(int monthsToAdd) {
    setState(() {
      _currentDate = DateTime(
        _currentDate.year,
        _currentDate.month + monthsToAdd,
        _currentDate.day,
      );
    });
  }

  List<Widget> _buildDonutChart(
    List<Map<String, dynamic>> categories,
    double totalSpent,
  ) {
    if (totalSpent == 0) {
      return [
        const SizedBox(
          width: 150,
          height: 150,
          child: CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 20,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE0E0E0)),
          ),
        ),
      ];
    }

    List<Widget> layers = [];
    double remainingPercent = 1.0;

    for (int i = categories.length - 1; i >= 0; i--) {
      var cat = categories[i];
      if (cat['percent'] > 0) {
        layers.add(
          SizedBox(
            width: 150,
            height: 150,
            child: CircularProgressIndicator(
              value: remainingPercent,
              strokeWidth: 20,
              valueColor: AlwaysStoppedAnimation<Color>(cat['color']),
              backgroundColor: Colors.transparent,
            ),
          ),
        );
        remainingPercent -= cat['percent'];
      }
    }
    return layers.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BudgetProvider>(context);
    List<Map<String, dynamic>> activeCategories = List.from(
      provider.categories,
    );
    activeCategories.sort((a, b) => b['amount'].compareTo(a['amount']));

    String formattedDate = DateFormat('MMMM yyyy', 'ar').format(_currentDate);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1026),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'التقارير',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDF0F5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(_periods.length, (index) {
                            bool isSelected = _selectedPeriodIndex == index;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedPeriodIndex = index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(
                                          0xFFF473B9,
                                        ).withValues(alpha: 0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  _periods[index],
                                  style: TextStyle(
                                    color: isSelected
                                        ? const Color(0xFFF473B9)
                                        : Colors.grey,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                          onPressed: () => _changeDate(-1),
                        ),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1B1E3F),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                          onPressed: () => _changeDate(1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  ..._buildDonutChart(
                                    activeCategories,
                                    provider.totalSpent,
                                  ),
                                  Container(
                                    width: 110,
                                    height: 110,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${provider.totalSpent.toInt()} \$',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          color: Color(0xFF1B1E3F),
                                        ),
                                      ),
                                      const Text(
                                        'إجمالي المصروف',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                              ...activeCategories
                                  .where((c) => c['amount'] > 0)
                                  .map(
                                    (cat) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 15.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 6,
                                                backgroundColor: cat['color'],
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                cat['name'],
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${(cat['percent'] * 100).toInt()}%',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: cat['color'],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              if (provider.totalSpent == 0)
                                const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Text(
                                    'لا توجد بيانات لهذا الشهر',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
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
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/transactions');
              },
              child: _buildNavItem(Icons.list_alt, 'المعاملات', Colors.white54),
            ),
            Container(
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
            GestureDetector(
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/categories'),
              child: _buildNavItem(Icons.category, 'التصنيفات', Colors.white54),
            ),
            _buildNavItem(Icons.bar_chart, 'التقارير', const Color(0xFFF7A2C5)),
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
