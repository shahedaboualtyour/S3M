import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/ai_transaction_service.dart'; // 🌟 تأكدي من صحة اسم ملف الخدمة الجديدة

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  int _currentState = 0;

  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isAnalyzing = false;
  String _spokenText = '';

  bool _isEnglish = false;

  // 🌟 استبدلنا المتغيرات المفردة بقائمة (List) لتستوعب عدة مصاريف 🌟
  List<dynamic> _extractedTransactions = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Status: $status'),
      onError: (error) => print('Error: $error'),
    );

    if (available) {
      setState(() {
        _currentState = 1;
        _isListening = true;
        _isAnalyzing = false;
        _spokenText = '';
      });

      _speech.listen(
        localeId: _isEnglish ? 'en_US' : 'ar_SA',
        onResult: (result) {
          setState(() {
            _spokenText = result.recognizedWords;
          });

          if (result.finalResult) {
            _isListening = false;
            _analyzeSpokenText(_spokenText);
          }
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('صلاحية المايكروفون غير متوفرة')),
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      _currentState = 0;
    });
  }

  Future<void> _analyzeSpokenText(String text) async {
    if (text.isEmpty) {
      _stopListening();
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    // 🌟 الاتصال بخدمة Groq AI الجديدة 🌟
    final aiResult = await AiTransactionService.parseVoiceText(text);

    if (aiResult['success'] && mounted) {
      setState(() {
        // حفظ قائمة المعاملات القادمة من الخادم
        _extractedTransactions = aiResult['transactions'];
        _isAnalyzing = false;
        _currentState = 2; // الانتقال لشاشة عرض النتائج
      });
    } else {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _currentState = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEnglish
                  ? 'Sorry, AI error: ${aiResult['message']}'
                  : 'عذراً، خطأ في الذكاء الاصطناعي: ${aiResult['message']}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 🌟 دالة مساعدة لاختيار الأيقونة حسب اسم الميزانية القادم من الخادم 🌟
  IconData _getIconForBudget(String? budgetName) {
    if (budgetName == null) return Icons.category;
    String nameLower = budgetName.toLowerCase();

    if (nameLower.contains('food') || nameLower.contains('طعام'))
      return Icons.restaurant;
    if (nameLower.contains('transport') || nameLower.contains('مواصلات'))
      return Icons.directions_car;
    if (nameLower.contains('shop') || nameLower.contains('تسوق'))
      return Icons.shopping_bag;
    if (nameLower.contains('bill') || nameLower.contains('فواتير'))
      return Icons.receipt_long;
    return Icons.account_balance_wallet;
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBg = Color(0xFF0D1026);

    return Scaffold(
      backgroundColor: primaryBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _isEnglish ? 'Record Transaction' : 'تسجيل صوتي',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _buildCurrentState(),
        ),
      ),
    );
  }

  Widget _buildCurrentState() {
    if (_currentState == 0) return _buildIdleState();
    if (_currentState == 1) return _buildRecordingState();
    return _buildResultState();
  }

  Widget _buildIdleState() {
    return Column(
      key: const ValueKey('idle'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _startListening,
          child: Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFF7A2C5), Color(0xFF8262A4)],
              ),
            ),
            child: const Icon(Icons.mic, color: Colors.white, size: 60),
          ),
        ),
        const SizedBox(height: 30),
        Container(
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => setState(() => _isEnglish = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: !_isEnglish
                        ? const Color(0xFF8262A4)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'عربي',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _isEnglish = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _isEnglish
                        ? const Color(0xFFF7A2C5)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'English',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Text(
          _isEnglish ? 'Tap and start speaking' : 'اضغط وابدأ التحدث',
          style: const TextStyle(color: Colors.white, fontSize: 22),
        ),
        Text(
          _isEnglish
              ? 'Ex: "I paid 50 for gas and 100 for food"'
              : 'مثال: "دفعت 50 مواصلات و 100 أكل"',
          style: const TextStyle(color: Colors.white54),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecordingState() {
    return Column(
      key: const ValueKey('recording'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _isAnalyzing
            ? const CircularProgressIndicator(color: Color(0xFFF7A2C5))
            : const Icon(Icons.graphic_eq, color: Color(0xFFF7A2C5), size: 100),
        const SizedBox(height: 20),
        Text(
          _isAnalyzing
              ? (_isEnglish
                    ? 'Analyzing with Groq AI...'
                    : 'جاري التحليل عبر Groq AI...')
              : (_isEnglish ? 'Listening to you...' : 'جارٍ الاستماع إليك...'),
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            _spokenText,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 40),
        if (!_isAnalyzing)
          ElevatedButton(
            onPressed: _stopListening,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(
              _isEnglish ? 'Cancel' : 'إلغاء',
              style: const TextStyle(color: Colors.white),
            ),
          ),
      ],
    );
  }

  // 🌟 واجهة النتائج المحدثة لتعرض قائمة (List) من المصاريف 🌟
  Widget _buildResultState() {
    return Padding(
      key: const ValueKey('result'),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text(
            _isEnglish
                ? '✨ AI Extracted Transactions'
                : '✨ المعاملات المستخرجة',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // استخدام Expanded لكي تأخذ القائمة المساحة المتبقية ولا تسبب Overflow
          Expanded(
            child: ListView.builder(
              itemCount: _extractedTransactions.length,
              itemBuilder: (context, index) {
                final tx = _extractedTransactions[index];
                return _buildTransactionCard(tx);
              },
            ),
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // 🌟 انتبهي: نحن نرجع القائمة كاملة الآن، وليس عنصراً واحداً 🌟
              Navigator.pop(context, _extractedTransactions);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8262A4),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(
              _isEnglish ? 'Confirm & Add All' : 'تأكيد وإضافة الكل',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _currentState = 0;
              });
            },
            child: Text(
              _isEnglish ? 'Record Again' : 'إعادة التسجيل',
              style: const TextStyle(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  // 🌟 تصميم بطاقة المعاملة الواحدة 🌟
  Widget _buildTransactionCard(Map<String, dynamic> tx) {
    String type = tx['type'] ?? 'expense'; // expense, income, donation
    double amount = (tx['amount'] ?? 0).toDouble();
    String? budgetName = tx['budget_name'];
    String description = tx['description'] ?? '';

    // تحديد اللون بناءً على النوع (مصروف أحمر، دخل أخضر، تبرع أزرق)
    Color typeColor = type == 'income'
        ? const Color(0xFF48CFAD)
        : (type == 'donation'
              ? const Color(0xFF5D9CEC)
              : const Color(0xFFF7A2C5));
    IconData icon = _getIconForBudget(budgetName);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            radius: 25,
            child: Icon(icon, color: const Color(0xFF8262A4), size: 25),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  budgetName ?? (_isEnglish ? 'Uncategorized' : 'غير مصنف'),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                type.toUpperCase(),
                style: TextStyle(
                  color: typeColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$amount \$',
                style: TextStyle(
                  color: typeColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
