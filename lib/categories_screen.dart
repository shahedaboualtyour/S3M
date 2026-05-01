import 'package:flutter/material.dart';
// 🌟 لا تنسي استيراد خدمة الـ API التي أنشأناها في الخطوة السابقة 🌟
import '../services/category_service.dart';

class CategoriesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;
  final List<Map<String, dynamic>> categories;

  const CategoriesScreen({
    super.key,
    required this.transactions,
    required this.categories,
  });

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late List<Map<String, dynamic>> _localCategories;
  double _totalSpent = 0.0;

  @override
  void initState() {
    super.initState();
    _localCategories = List.from(widget.categories);
    _calculateCategoryData();
  }

  void _calculateCategoryData() {
    _totalSpent = 0.0;

    for (var cat in _localCategories) {
      double catTotal = 0.0;
      for (var tx in widget.transactions) {
        if (tx['category'] == cat['name']) {
          catTotal += tx['amount'];
        }
      }
      cat['amount'] = catTotal;
      _totalSpent += catTotal;
    }

    for (var cat in _localCategories) {
      cat['percent'] = _totalSpent > 0 ? (cat['amount'] / _totalSpent) : 0.0;
    }

    _localCategories.sort((a, b) => b['amount'].compareTo(a['amount']));
  }

  // 🌟 دوال مساعدة لتحويل الألوان والأيقونات ليفهمها الـ Backend 🌟
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  String _iconToString(IconData icon) {
    // يمكنك هنا عمل خريطة (Map) لتحويل الأيقونة لاسم نصي يفهمه الـ Backend
    if (icon == Icons.fastfood) return 'food-icon';
    if (icon == Icons.flight) return 'travel-icon';
    if (icon == Icons.local_hospital) return 'health-icon';
    return 'default-icon';
  }

  void _showAddCategoryDialog() {
    String newName = '';
    IconData selectedIcon = Icons.star;
    Color selectedColor = const Color(0xFFF7A2C5);
    bool isSaving = false; // 🌟 متغير جديد لتتبع حالة التحميل داخل النافذة 🌟

    List<IconData> availableIcons = [
      Icons.star,
      Icons.fastfood,
      Icons.local_hospital,
      Icons.flight,
      Icons.school,
      Icons.fitness_center,
      Icons.pets,
      Icons.home,
    ];
    List<Color> availableColors = [
      const Color(0xFFF473B9),
      const Color(0xFF5D9CEC),
      const Color(0xFFAC92EC),
      const Color(0xFFFFCE54),
      const Color(0xFF48CFAD),
      Colors.redAccent,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'إضافة تصنيف جديد',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'اسم التصنيف (مثال: صحة، تعليم)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onChanged: (value) => newName = value,
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'اختر أيقونة:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 15,
                    runSpacing: 10,
                    children: availableIcons
                        .map(
                          (icon) => GestureDetector(
                            onTap: () =>
                                setModalState(() => selectedIcon = icon),
                            child: CircleAvatar(
                              backgroundColor: selectedIcon == icon
                                  ? selectedColor
                                  : Colors.grey.shade200,
                              child: Icon(
                                icon,
                                color: selectedIcon == icon
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'اختر لوناً:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 15,
                    runSpacing: 10,
                    children: availableColors
                        .map(
                          (color) => GestureDetector(
                            onTap: () =>
                                setModalState(() => selectedColor = color),
                            child: CircleAvatar(
                              backgroundColor: color,
                              child: selectedColor == color
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : null,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            if (newName.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('الرجاء إدخال اسم التصنيف'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            setModalState(() {
                              isSaving = true;
                            });

                            String hexColor = _colorToHex(selectedColor);
                            String iconString = _iconToString(selectedIcon);

                            final result = await CategoryService.createCategory(
                              newName,
                              iconString,
                              hexColor,
                            );

                            if (!mounted) return;

                            if (result['success']) {
                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['message']),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              setState(() {
                                _localCategories.add({
                                  'id': result['category']['id'],
                                  'name': newName,
                                  'color': selectedColor,
                                  'icon': selectedIcon,
                                  'amount': 0.0,
                                  'percent': 0.0,
                                });
                                _calculateCategoryData();
                              });
                            } else {
                              setModalState(() {
                                isSaving = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['message']),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8262A4),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),

                    child: isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'حفظ التصنيف',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildDynamicPieChart() {
    if (_totalSpent == 0) {
      return [
        const SizedBox(
          width: 120,
          height: 120,
          child: CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 15,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE0E0E0)),
          ),
        ),
      ];
    }

    List<Widget> layers = [];
    double remainingPercent = 1.0;

    for (int i = _localCategories.length - 1; i >= 0; i--) {
      var cat = _localCategories[i];
      if (cat['percent'] > 0) {
        layers.add(
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: remainingPercent,
              strokeWidth: 15,
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _localCategories);
        return false;
      },
      child: Scaffold(
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
                      onPressed: () => Navigator.pop(context, _localCategories),
                    ),
                    const Column(
                      children: [
                        Text(
                          'التصنيفات',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'إدارة فئات مصاريفك',
                          style: TextStyle(fontSize: 12, color: Colors.white54),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: _showAddCategoryDialog,
                      ),
                    ),
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
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
                          child: Row(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  ..._buildDynamicPieChart(),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${_totalSpent.toInt()}\$',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
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
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'توزيع المصروف حسب الفئات',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ..._localCategories
                                        .where((c) => c['amount'] > 0)
                                        .map(
                                          (cat) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 6.0,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 4,
                                                      backgroundColor:
                                                          cat['color'],
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      cat['name'],
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  '${(cat['percent'] * 100).toInt()}%',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: cat['color'],
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    if (_totalSpent == 0)
                                      const Text(
                                        'لا يوجد صرف بعد',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 11,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'الفئات',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF1B1E3F),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        ..._localCategories.map(
                          (cat) => _buildCategoryCard(cat),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> cat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cat['color'].withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(cat['icon'], color: cat['color']),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      '${cat['amount'].toInt()}\$  •  ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${(cat['percent'] * 100).toInt()}% من إجمالي المصروف',
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: cat['percent'],
                    minHeight: 6,
                    backgroundColor: cat['color'].withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(cat['color']),
                  ),
                ),
              ],
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
              onTap: () => Navigator.pop(context, _localCategories),
              child: _buildNavItem(Icons.home, 'الرئيسية', Colors.white54),
            ),
            _buildNavItem(Icons.list_alt, 'المعاملات', Colors.white54),
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
            _buildNavItem(Icons.category, 'التصنيفات', const Color(0xFFF7A2C5)),
            _buildNavItem(Icons.bar_chart, 'التقارير', Colors.white54),
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
