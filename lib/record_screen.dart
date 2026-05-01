import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/ai_service.dart';

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

  String _extractedAmount = '0.00';
  String _extractedCategory = 'غير مصنف';
  String _extractedDescription = '';
  IconData _categoryIcon = Icons.help_outline;

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

    final aiResult = await AiService.analyzeExpense(text);

    if (aiResult != null && mounted) {
      setState(() {
        _extractedAmount = aiResult['amount'].toString();
        _extractedDescription = aiResult['title'];
        _extractedCategory = aiResult['category'];

        if (_extractedCategory == 'أكل ومشروبات')
          _categoryIcon = Icons.restaurant;
        else if (_extractedCategory == 'مواصلات')
          _categoryIcon = Icons.directions_car;
        else if (_extractedCategory == 'تسوق')
          _categoryIcon = Icons.shopping_bag;
        else if (_extractedCategory == 'فواتير وخدمات')
          _categoryIcon = Icons.receipt_long;
        else
          _categoryIcon = Icons.category;

        _isAnalyzing = false;
        _currentState = 2;
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
                  ? 'Sorry, I couldn\'t understand that. Please try again.'
                  : 'عذراً، لم أتمكن من فهمك جيداً. يرجى المحاولة مجدداً.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          _isEnglish ? 'Record Expense' : 'تسجيل مصروف',
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
              ? 'Example: "I paid 50 dollars for gas"'
              : 'مثال: "والله صلحت سيارتي بـ 50 دولار"',
          style: const TextStyle(color: Colors.white54),
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
              ? (_isEnglish ? 'Analyzing smartly...' : 'جاري التحليل بذكاء...')
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

  Widget _buildResultState() {
    return Padding(
      key: const ValueKey('result'),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isEnglish
                ? '✨ Understood by AI'
                : '✨ تم الفهم بفضل الذكاء الاصطناعي',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      radius: 30,
                      child: Icon(
                        _categoryIcon,
                        color: const Color(0xFF8262A4),
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEnglish ? 'Description' : 'الوصف',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _extractedDescription,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _isEnglish ? 'Amount' : 'المبلغ',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '$_extractedAmount \$',
                          style: const TextStyle(
                            color: Color(0xFFF7A2C5),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDetailItem(
                      Icons.category,
                      _isEnglish ? 'Category' : 'الفئة',
                      _extractedCategory,
                    ),
                    _buildDetailItem(
                      Icons.calendar_today,
                      _isEnglish ? 'Date' : 'التاريخ',
                      _isEnglish ? 'Today' : 'اليوم',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, {
                'title': _extractedDescription,
                'amount': double.tryParse(_extractedAmount) ?? 0.0,
                'category': _extractedCategory,
                'icon': _categoryIcon,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8262A4),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(
              _isEnglish ? 'Confirm & Add' : 'تأكيد وإضافة',
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

  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF8262A4), size: 20),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
