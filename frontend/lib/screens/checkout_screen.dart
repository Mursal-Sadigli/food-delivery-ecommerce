import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wallet_provider.dart';
import 'order_tracking_screen.dart';
import 'main_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedMethod = 0;
  bool _isProcessing = false;
  final _promoController = TextEditingController();

  final Color _purpleBg = const Color(0xFF3B1D8F);

  void _processPayment() async {
    setState(() => _isProcessing = true);
    
    if (_selectedMethod == 3) {
      final wallet = Provider.of<WalletProvider>(context, listen: false);
      final cart = Provider.of<CartProvider>(context, listen: false);
      final total = cart.finalPrice + 8.0;

      if (wallet.balance < total) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cüzdan balansınız kifayət deyil'), backgroundColor: Colors.red),
        );
        return;
      }
      
      // Simulation: subtract from wallet
      // In a real app, this would be a backend call
      await wallet.deposit(-total); 
    }

    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isProcessing = false);

    if (mounted) {
      Provider.of<CartProvider>(context, listen: false).clear();
      _showSuccessPopup();
    }
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: _purpleBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 45),
              ),
              const SizedBox(height: 24),
              const Text(
                'Thank You For\nYour Order',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your Order Been Place Successfully!\nYou Can Track The Delivery In The\nOrder Section',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreen()), (route) => false);
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: const Text('Back Home', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OrderTrackingScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purpleBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Track Your Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'You Can Order Something Else',
                style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final deliveryFee = 8.0;
    final total = cart.finalPrice + deliveryFee;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
              ),
            ),
          ),
        ),
        title: Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Purple Credit Card Map (Like the image)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5D3EBC), Color(0xFF3B1D8F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: _purpleBg.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('David Michael', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
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
                    const Text(
                      '4563   1122   4695   7852',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _cardLabelVal('Exp Date', '16/24'),
                        _cardLabelVal('CVC Number', '972'),
                        const Text('Master Card', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Choose Payment Method horizontally
              Text('Choose Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _paymentMethodChip(0, Icons.circle, isMastercard: true)),
                  const SizedBox(width: 8),
                  Expanded(child: _paymentMethodChip(1, Icons.paypal, color: Colors.blue)),
                  const SizedBox(width: 8),
                  Expanded(child: _paymentMethodChip(2, Icons.apple, color: Colors.black)),
                  const SizedBox(width: 8),
                  Expanded(child: _paymentMethodChip(3, Icons.account_balance_wallet, color: const Color(0xFFFF5722))),
                ],
              ),
              const SizedBox(height: 32),

              // Promo Code
              Text('Promo Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promoController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Promo code',
                          hintStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey),
                          border: InputBorder.none,
                          suffixIcon: cart.appliedCoupon != null 
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.red, size: 20),
                                onPressed: () {
                                  cart.removeCoupon();
                                  _promoController.clear();
                                },
                              )
                            : null,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cart.appliedCoupon != null ? Colors.green : Colors.black87,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      onPressed: cart.appliedCoupon != null ? null : () async {
                        if (_promoController.text.isEmpty) return;
                        final error = await cart.applyPromoCode(_promoController.text);
                        if (error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error), backgroundColor: Colors.red),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Promo kod tətbiq edildi!'), backgroundColor: Colors.green),
                          );
                        }
                      },
                      child: Text(cart.appliedCoupon != null ? 'Applied' : 'Apply', style: const TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Breakdown
              if (cart.discount > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal', style: TextStyle(color: Colors.grey)),
                    Text('${cart.totalPrice.toStringAsFixed(2)} ₼', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Discount', style: TextStyle(color: Colors.green)),
                    Text('-${cart.discount.toStringAsFixed(2)} ₼', style: const TextStyle(color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Delivery', style: TextStyle(color: Colors.grey)),
                    Text('${deliveryFee.toStringAsFixed(2)} ₼', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                  ],
                ),
                const Divider(height: 32),
              ],

              // Total Payment
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                  Text('${total.toStringAsFixed(2)} ₼', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                ],
              ),
              const SizedBox(height: 24),

              // Payment Button
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purpleBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 5,
                    shadowColor: _purpleBg.withOpacity(0.5),
                  ),
                  child: _isProcessing
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardLabelVal(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _paymentMethodChip(int index, IconData icon, {Color? color, bool isMastercard = false}) {
    final isSelected = _selectedMethod == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? _purpleBg : (isDark ? Colors.grey[800] : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? null : Border.all(color: isDark ? Colors.grey[700]! : Colors.grey.shade300),
          boxShadow: isSelected ? [BoxShadow(color: _purpleBg.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))] : [],
        ),
        child: Center(
          child: isMastercard
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 14, height: 14, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                    Transform.translate(
                      offset: const Offset(-6, 0),
                      child: Container(width: 14, height: 14, decoration: BoxDecoration(color: Colors.orange.withOpacity(0.9), shape: BoxShape.circle)),
                    ),
                  ],
                )
              : Icon(icon, color: isSelected ? Colors.white : color),
        ),
      ),
    );
  }
}
