import 'package:flutter/material.dart';

class ReviewTransactionsScreen extends StatefulWidget {
  const ReviewTransactionsScreen({super.key});

  @override
  State<ReviewTransactionsScreen> createState() =>
      _ReviewTransactionsScreenState();
}

class _ReviewTransactionsScreenState extends State<ReviewTransactionsScreen> {
  // 1. البيانات المبدئية المحولة من الـ JSON الذي أرسلتِه
  // نضعها في متغير State لكي نتمكن من تعديلها وحذفها
  List<Map<String, dynamic>> _transactions = [
    {
      "budget_id": null,
      "budget_name": null,
      "type": "deposit",
      "amount": 500,
      "description": "won from a game at school",
    },
    {
      "budget_id": null,
      "budget_name": null,
      "type": "expense",
      "amount": 100,
      "description": "tea",
    },
    {
      "budget_id": null,
      "budget_name": null,
      "type": "expense",
      "amount": 20000,
      "description": "apple",
    },
    {
      "budget_id": null,
      "budget_name": null,
      "type": "expense",
      "amount": 1000,
      "description": "books",
    },
    {
      "budget_id": null,
      "budget_name": null,
      "type": "expense",
      "amount": 900,
      "description": "cookie",
    },
    {
      "budget_id": null,
      "budget_name": null,
      "type": "expense",
      "amount": 100,
      "description": "bill",
    },
  ];

  // 2. دالة الحذف
  void _deleteTransaction(int index) {
    setState(() {
      _transactions.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حذف العملية'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // 3. دالة التعديل (تظهر نافذة منبثقة لتعديل المبلغ أو الوصف)
  void _editTransaction(int index) {
    TextEditingController amountCtrl = TextEditingController(
      text: _transactions[index]['amount'].toString(),
    );
    TextEditingController descCtrl = TextEditingController(
      text: _transactions[index]['description'],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2147),
          title: const Text(
            'تعديل العملية',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'الوصف',
                  labelStyle: TextStyle(color: Colors.white54),
                ),
              ),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'المبلغ',
                  labelStyle: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'إلغاء',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF7A2C5),
              ),
              onPressed: () {
                setState(() {
                  _transactions[index]['description'] = descCtrl.text;
                  _transactions[index]['amount'] =
                      double.tryParse(amountCtrl.text) ??
                      _transactions[index]['amount'];
                });
                Navigator.pop(context);
              },
              child: const Text('حفظ', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  // دالة مساعدة لتحديد الأيقونة واللون بناءً على الوصف والنوع
  IconData _getIcon(String desc, String type) {
    if (type == 'deposit') return Icons.attach_money;
    if (desc.toLowerCase().contains('tea') ||
        desc.toLowerCase().contains('cookie') ||
        desc.toLowerCase().contains('apple'))
      return Icons.restaurant;
    if (desc.toLowerCase().contains('book')) return Icons.menu_book;
    if (desc.toLowerCase().contains('bill')) return Icons.receipt_long;
    return Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1026),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long, color: Color(0xFFF7A2C5), size: 20),
                SizedBox(width: 8),
                Text(
                  'مراجعة العمليات',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              'تأكد من التفاصيل قبل الإضافة',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic, color: Color(0xFF8262A4)),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // البانر العلوي التوضيحي
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF0F5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تم استخراج هذه العمليات',
                        style: TextStyle(
                          color: Color(0xFF1B1E3F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.mic, color: Color(0xFF8262A4), size: 16),
                          SizedBox(width: 5),
                          Text(
                            'من التسجيل الصوتي',
                            style: TextStyle(color: Color(0xFF8262A4)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Icon(
                    Icons.auto_awesome,
                    color: const Color(0xFF8262A4).withOpacity(0.5),
                    size: 40,
                  ),
                ],
              ),
            ),

            // عنوان القائمة
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'العمليات المستخرجة (${_transactions.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'المبلغ',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 🌟 القائمة (ListView) 🌟
            Expanded(
              child: _transactions.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد عمليات',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final tx = _transactions[index];
                        final isExpense = tx['type'] == 'expense';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2147),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              // أيقونة الفئة
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isExpense
                                      ? const Color(0xFFFDF0F5)
                                      : const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getIcon(tx['description'], tx['type']),
                                  color: isExpense
                                      ? const Color(0xFFF7A2C5)
                                      : Colors.green,
                                ),
                              ),
                              const SizedBox(width: 15),

                              // تفاصيل العملية
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tx['description'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        tx['budget_name'] ?? 'غير مصنف',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // المبلغ (بدون رمز العملة كما طلبتِ)
                              Text(
                                '${isExpense ? '-' : '+'}${tx['amount']}',
                                style: TextStyle(
                                  color: isExpense
                                      ? const Color(0xFFF7A2C5)
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 15),

                              // أزرار التعديل والحذف
                              Column(
                                children: [
                                  InkWell(
                                    onTap: () => _editTransaction(index),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Color(0xFF8262A4),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  InkWell(
                                    onTap: () => _deleteTransaction(index),
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.white54,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // زر الإضافة اليدوية
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF8262A4)),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  '+ إضافة عنصر يدوياً',
                  style: TextStyle(
                    color: Color(0xFF8262A4),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // 🌟 الأزرار السفلية (تمت إزالة ملخص العمليات) 🌟
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF1E2147),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // هنا سيتم إرسال الـ _transactions للـ Backend
                      Navigator.pop(context, _transactions);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF7A2C5),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'تأكيد جميع العمليات (${_transactions.length})',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white54,
                          size: 16,
                        ),
                        label: const Text(
                          'تعديل الكل',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.add_comment,
                          color: Colors.white54,
                          size: 16,
                        ),
                        label: const Text(
                          'إضافة ملاحظة',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'إلغاء العملية',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
