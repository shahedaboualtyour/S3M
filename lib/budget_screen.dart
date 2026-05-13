import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// 🌟 أزلنا استيراد BudgetService لأننا لن نتصل بالباك إند حالياً 🌟

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  double _budgetAmount = 600.0;
  double _sliderMax = 5000.0;
  DateTime _startDate = DateTime.now();

  bool _isLoading = false;
  String _selectedCycle = 'monthly';

  final Map<String, String> _cycleOptions = {
    'daily': 'يومي',
    'weekly': 'أسبوعي',
    'monthly': 'شهري',
    'yearly': 'سنوي',
  };

  final TextEditingController _amountController = TextEditingController(
    text: "600",
  );
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF8262A4)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  // 🌟 دالة مساعدة لحساب تاريخ الانتهاء بناءً على دورة التجديد 🌟
  DateTime _calculateEndDate(DateTime start, String cycle) {
    switch (cycle) {
      case 'daily':
        return start.add(const Duration(days: 1));
      case 'weekly':
        return start.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(start.year, start.month + 1, start.day);
      case 'yearly':
        return DateTime(start.year + 1, start.month, start.day);
      default:
        return start.add(const Duration(days: 30));
    }
  }

  // 🌟 تعديل دالة الحفظ لتعمل محلياً (Mock Data) 🌟
  Future<void> _saveBudget() async {
    String name = _nameController.text.trim();

    // 1. التحقق من صحة البيانات (Validation)
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال اسم الميزانية'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true; // تشغيل تأثير التحميل
    });

    // 2. محاكاة الاتصال بالخادم (تأخير لمدة ثانية ونصف)
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    setState(() {
      _isLoading = false; // إيقاف التحميل
    });

    // رسالة نجاح وهمية
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إنشاء الميزانية بنجاح (محلياً)'),
        backgroundColor: Colors.green,
      ),
    );

    // 3. تجهيز بيانات الميزانية وإرسالها للشاشة السابقة (HomeScreen)
    Map<String, dynamic> mockBudget = {
      'name': name,
      'amount': _budgetAmount,
      'start': _startDate,
      'end': _calculateEndDate(_startDate, _selectedCycle), // حساب النهاية
    };

    // إغلاق الشاشة وإرجاع البيانات
    Navigator.pop(context, mockBudget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDF0F5), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'إدارة الميزانية',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Icon(Icons.bar_chart, color: Color(0xFF8262A4)),
                  ],
                ),
              ),

              Expanded(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'اسم الميزانية',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B1E3F),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                hintText: 'مثال: ميزانية البيت، السفر...',
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(
                                  Icons.edit_note,
                                  color: Color(0xFFF7A2C5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Container(
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
                            const Text(
                              'المبلغ',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  '\$ ',
                                  style: TextStyle(
                                    color: Color(0xFFF7A2C5),
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IntrinsicWidth(
                                  child: TextField(
                                    controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFF1B1E3F),
                                      fontSize: 50,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                    onChanged: (value) {
                                      double? parsed = double.tryParse(value);
                                      if (parsed != null) {
                                        setState(() {
                                          _budgetAmount = parsed;
                                          if (parsed > _sliderMax) {
                                            _sliderMax = parsed;
                                          }
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Slider(
                              value: _budgetAmount.clamp(0.0, _sliderMax),
                              min: 0,
                              max: _sliderMax,
                              activeColor: const Color(0xFFF7A2C5),
                              inactiveColor: const Color(
                                0xFF1B1E3F,
                              ).withValues(alpha: 0.1),
                              onChanged: (value) {
                                setState(() {
                                  _budgetAmount = value;
                                  _amountController.text = value
                                      .toInt()
                                      .toString();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'إعدادات التجديد',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _selectDate(context),
                                    child: _buildDateBox(
                                      'تاريخ البداية',
                                      DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(_startDate),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'دورة التجديد',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: _selectedCycle,
                                            isExpanded: true,
                                            icon: const Icon(
                                              Icons.autorenew,
                                              color: Color(0xFFF7A2C5),
                                              size: 18,
                                            ),
                                            items: _cycleOptions.entries.map((
                                              entry,
                                            ) {
                                              return DropdownMenuItem<String>(
                                                value: entry.key,
                                                child: Center(
                                                  child: Text(
                                                    entry.value,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  _selectedCycle = newValue;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveBudget,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8262A4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'حفظ الميزانية',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateBox(String title, String date) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.calendar_today,
                size: 14,
                color: Color(0xFFF7A2C5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
