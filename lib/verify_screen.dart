import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';

class VerifyScreen extends StatefulWidget {
  final String email;

  const VerifyScreen({super.key, required this.email});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final TextEditingController _box1 = TextEditingController();
  final TextEditingController _box2 = TextEditingController();
  final TextEditingController _box3 = TextEditingController();
  final TextEditingController _box4 = TextEditingController();
  final TextEditingController _box5 = TextEditingController();
  final TextEditingController _box6 = TextEditingController();

  final FocusNode _focus1 = FocusNode();
  final FocusNode _focus2 = FocusNode();
  final FocusNode _focus3 = FocusNode();
  final FocusNode _focus4 = FocusNode();
  final FocusNode _focus5 = FocusNode();
  final FocusNode _focus6 = FocusNode();

  bool _isLoading = false;

  void _verifyCode() {
    String code =
        _box1.text +
        _box2.text +
        _box3.text +
        _box4.text +
        _box5.text +
        _box6.text;

    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال الرمز المكون من 6 أرقام كاملة'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم توثيق الحساب بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _box1.dispose();
    _box2.dispose();
    _box3.dispose();
    _box4.dispose();
    _box5.dispose();
    _box6.dispose();
    _focus1.dispose();
    _focus2.dispose();
    _focus3.dispose();
    _focus4.dispose();
    _focus5.dispose();
    _focus6.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2147),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                size: 80,
                color: Color(0xFFF7A2C5),
              ),
              const SizedBox(height: 30),
              const Text(
                'توثيق الحساب',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'أدخل الرمز المكون من 6 أرقام الذي أرسلناه إلى\n${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildOtpBox(
                    controller: _box1,
                    focusNode: _focus1,
                    nextFocus: _focus2,
                  ),
                  _buildOtpBox(
                    controller: _box2,
                    focusNode: _focus2,
                    nextFocus: _focus3,
                    prevFocus: _focus1,
                  ),
                  _buildOtpBox(
                    controller: _box3,
                    focusNode: _focus3,
                    nextFocus: _focus4,
                    prevFocus: _focus2,
                  ),
                  _buildOtpBox(
                    controller: _box4,
                    focusNode: _focus4,
                    nextFocus: _focus5,
                    prevFocus: _focus3,
                  ),
                  _buildOtpBox(
                    controller: _box5,
                    focusNode: _focus5,
                    nextFocus: _focus6,
                    prevFocus: _focus4,
                  ),
                  _buildOtpBox(
                    controller: _box6,
                    focusNode: _focus6,
                    prevFocus: _focus5,
                  ),
                ],
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8262A4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'تحقق الآن',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم إرسال رمز جديد إلى بريدك'),
                    ),
                  );
                },
                child: const Text(
                  'لم يصلك الرمز؟ إعادة إرسال',
                  style: TextStyle(
                    color: Color(0xFFF7A2C5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    FocusNode? prevFocus,
  }) {
    return SizedBox(
      width: 45,
      height: 55,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),

        autofillHints: const [AutofillHints.oneTimeCode],
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.isNotEmpty && nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          } else if (value.isEmpty && prevFocus != null) {
            FocusScope.of(context).requestFocus(prevFocus);
          }
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.1),
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFF7A2C5), width: 2),
          ),
        ),
      ),
    );
  }
}
