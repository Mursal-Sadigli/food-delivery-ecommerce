import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  void _showAddMethodBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const _AddCardBottomSheetContent();
      }
    );
  }

  void _removeMethod(String id) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.removePaymentMethod(id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ödəniş üsulu silindi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    final methods = user?['paymentMethods'] as List<dynamic>? ?? [];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Ödəniş Üsulları', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: methods.isEmpty
          ? Center(child: Text('Hələ heç bir ödəniş üsulu əlavə edilməyib.', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: methods.length,
              itemBuilder: (context, index) {
                final method = methods[index];
                final isDefaultCard = method['isDefault'] == true;

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: isDefaultCard 
                      ? const LinearGradient(
                          colors: [Color(0xFF5D3EBC), Color(0xFF3B1D8F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: isDark ? [Colors.grey[800]!, Colors.grey[900]!] : [Colors.grey.shade100, Colors.grey.shade200],
                        ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: isDefaultCard 
                      ? [BoxShadow(color: const Color(0xFF3B1D8F).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]
                      : [],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              method['cardHolderName'] ?? 'Bilinmir', 
                              style: TextStyle(color: isDefaultCard || isDark ? Colors.white : Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              Container(width: 14, height: 14, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                              Transform.translate(
                                offset: const Offset(-6, 0),
                                child: Container(width: 14, height: 14, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '**** **** **** ${method['cardNumber'].toString().length >= 4 ? method['cardNumber'].toString().substring(method['cardNumber'].toString().length - 4) : method['cardNumber']}',
                                style: TextStyle(color: isDefaultCard || isDark ? Colors.white : Colors.black87, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: isDefaultCard ? Colors.white70 : Colors.red),
                            onPressed: () => _removeMethod(method['_id']),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Bitmə Tarixi', style: TextStyle(color: isDefaultCard || isDark ? Colors.white70 : Colors.black54, fontSize: 10)),
                                const SizedBox(height: 4),
                                Text(method['expiryDate'] ?? '', style: TextStyle(color: isDefaultCard || isDark ? Colors.white : Colors.black87, fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          if (isDefaultCard)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                              child: const Text('Əsas Ödəniş', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            )
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF3B1D8F),
        onPressed: _showAddMethodBottomSheet,
        icon: const Icon(Icons.add_card, color: Colors.white),
        label: const Text('Yeni Kart Əlavə Et', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(' ', '');
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      int index = i + 1;
      if (index % 4 == 0 && text.length != index) {
        buffer.write(' ');
      }
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll('/', '');
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1 && text.length != i + 1) {
        buffer.write('/');
      }
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _AddCardBottomSheetContent extends StatefulWidget {
  const _AddCardBottomSheetContent();

  @override
  State<_AddCardBottomSheetContent> createState() => _AddCardBottomSheetContentState();
}

class _AddCardBottomSheetContentState extends State<_AddCardBottomSheetContent> with SingleTickerProviderStateMixin {
  final holderCtrl = TextEditingController();
  final numberCtrl = TextEditingController();
  final expiryCtrl = TextEditingController();
  final cvvCtrl = TextEditingController();
  
  final FocusNode cvvFocusNode = FocusNode();
  bool isDefault = false;
  
  late AnimationController _animController;
  late Animation<double> _anim;
  
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _anim = Tween<double>(begin: 0, end: math.pi).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
    
    cvvFocusNode.addListener(() {
      if (cvvFocusNode.hasFocus) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });

    holderCtrl.addListener(() => setState(() {}));
    numberCtrl.addListener(() => setState(() {}));
    expiryCtrl.addListener(() => setState(() {}));
    cvvCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    holderCtrl.dispose();
    numberCtrl.dispose();
    expiryCtrl.dispose();
    cvvCtrl.dispose();
    cvvFocusNode.dispose();
    _animController.dispose();
    super.dispose();
  }
  
  Widget _buildCardFront(bool isDark) {
    final number = numberCtrl.text.isEmpty ? '**** **** **** ****' : numberCtrl.text;
    final holder = holderCtrl.text.isEmpty ? 'AD SOYAD' : holderCtrl.text.toUpperCase();
    final expiry = expiryCtrl.text.isEmpty ? 'MM/YY' : expiryCtrl.text;
    
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5D3EBC), Color(0xFF3B1D8F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF3B1D8F).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.contactless_outlined, color: Colors.white, size: 32),
              Row(
                children: [
                   Container(width: 14, height: 14, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                   Transform.translate(offset: const Offset(-6, 0), child: Container(width: 14, height: 14, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle))),
                ],
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sahibi', style: TextStyle(color: Colors.white70, fontSize: 10)),
                    Text(holder, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Bitmə', style: TextStyle(color: Colors.white70, fontSize: 10)),
                  Text(expiry, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(bool isDark) {
    final cvv = cvvCtrl.text.isEmpty ? '***' : cvvCtrl.text;
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5D3EBC), Color(0xFF3B1D8F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF3B1D8F).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Container(width: double.infinity, height: 45, color: Colors.black87),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(child: Container(height: 35, color: Colors.white)),
                Container(
                  height: 35,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.grey.shade300, border: Border.all(color: Colors.grey.shade400)),
                  child: Text(cvv, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                ),
              ],
            ),
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Text('Bu kart yalnız elektron ticarət təyinatlıdır. Zəhmət olmasa təhlükəsiz saxlayın.', style: TextStyle(color: Colors.white54, fontSize: 8)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, required String hint, required TextEditingController controller, TextInputType type = TextInputType.text, FocusNode? focusNode, List<TextInputFormatter>? formatters, int? maxLength}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: type,
          focusNode: focusNode,
          inputFormatters: formatters,
          maxLength: maxLength,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
            filled: true,
            fillColor: isDark ? Colors.grey[800] : Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: const Color(0xFF3B1D8F), width: 2)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.only(
        left: 24, 
        right: 24, 
        top: 24, 
        bottom: MediaQuery.of(context).viewInsets.bottom + 24
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(color: isDark ? Colors.grey[700] : Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 24),
            Text('Yeni Kart Əlavə Et', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 24),
            
            AnimatedBuilder(
              animation: _anim,
              builder: (context, child) {
                final angle = _anim.value;
                return Transform(
                  transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angle),
                  alignment: Alignment.center,
                  child: angle < math.pi / 2
                      ? _buildCardFront(isDark)
                      : Transform(
                          transform: Matrix4.identity()..rotateY(math.pi),
                          alignment: Alignment.center,
                          child: _buildCardBack(isDark),
                        ),
                );
              },
            ),
            const SizedBox(height: 32),
            
            _buildTextField(label: 'Kart Nömrəsi', hint: '0000 0000 0000 0000', controller: numberCtrl, type: TextInputType.number, formatters: [FilteringTextInputFormatter.digitsOnly, CardNumberFormatter()], maxLength: 19),
            const SizedBox(height: 16),
            _buildTextField(label: 'Kart Üzərindəki Ad', hint: 'Məs: ALİ ƏLİYEV', controller: holderCtrl),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField(label: 'Bitmə Tarixi', hint: 'MM/YY', controller: expiryCtrl, type: TextInputType.number, formatters: [FilteringTextInputFormatter.digitsOnly, ExpiryDateFormatter()], maxLength: 5)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(label: 'CVV', hint: '***', controller: cvvCtrl, type: TextInputType.number, focusNode: cvvFocusNode, formatters: [FilteringTextInputFormatter.digitsOnly], maxLength: 4)),
              ],
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Əsas ödəniş üsulu olsun?', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              activeColor: const Color(0xFF3B1D8F),
              value: isDefault,
              onChanged: (val) {
                setState(() { isDefault = val ?? false; });
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B1D8F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                  if (holderCtrl.text.isEmpty || numberCtrl.text.isEmpty) return;
                  
                  final auth = Provider.of<AuthProvider>(context, listen: false);
                  final success = await auth.addPaymentMethod({
                    'cardHolderName': holderCtrl.text,
                    'cardNumber': numberCtrl.text.replaceAll(' ', ''),
                    'expiryDate': expiryCtrl.text,
                    'isDefault': isDefault,
                  });
                  if (success && mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ödəniş üsulu uğurla əlavə edildi')),
                    );
                  }
                },
                child: const Text('Təsdiqlə və Əlavə Et', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
