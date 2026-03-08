import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wallet_provider.dart';
import 'order_tracking_screen.dart';
import 'main_screen.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedMethod = 0;
  bool _isProcessing = false;
  final _promoController = TextEditingController();
  
  bool _isScheduled = false;
  DateTime? _scheduledDateTime;

  final Color _accentColor = const Color(0xFF673AB7);

  void _processPayment() async {
    setState(() => _isProcessing = true);
    
    final cart = Provider.of<CartProvider>(context, listen: false);
    final wallet = Provider.of<WalletProvider>(context, listen: false);
    final total = cart.finalPrice + 8.0;

    if (_selectedMethod == 3) {
      if (wallet.balance < total) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cüzdan balansınız kifayət deyil'), backgroundColor: Colors.red),
        );
        return;
      }
      // Simulation: subtract from wallet
      await wallet.deposit(-total); 
    }

    try {
      // Real API call to create order
      final response = await cart.createOrder(
        shippingAddress: {
          'address': 'Mərkəzi k., 45', // Mock address for demo
          'city': 'Bakı',
          'postalCode': 'AZ1000',
          'country': 'Azərbaycan',
        },
        paymentMethod: _selectedMethod == 0 ? 'Kart' : (_selectedMethod == 1 ? 'Paypal' : 'Cüzdan'),
        scheduledAt: _isScheduled ? _scheduledDateTime : null,
      );

      setState(() => _isProcessing = false);

      if (response != null && mounted) {
        _showSuccessPopup();
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sifariş yaradılarkən xəta: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showSuccessPopup() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curve = Curves.elasticOut.transform(anim1.value);
        return Transform.scale(
          scale: curve,
          child: Opacity(
            opacity: anim1.value,
            child: Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Təşəkkür Edirik!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sifarişiniz uğurla yerləşdirildi.\nTezliklə çatdırılacaq.',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreen()), (route) => false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        child: const Text('Ana Səhifəyə Qayıt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OrderTrackingScreen()));
                      },
                      child: Text(
                        'Sifarişi İzlə',
                        style: TextStyle(color: _accentColor, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
              // Premium Credit Card (Glassmorphism + Mesh Gradient)
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(
                    children: [
                      // Mesh Gradient Background
                      Positioned.fill(
                        child: Container(color: const Color(0xFF0F0F0F)),
                      ),
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                _accentColor.withOpacity(0.6),
                                _accentColor.withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -100,
                        left: -50,
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFE91E63).withOpacity(0.4),
                                const Color(0xFFE91E63).withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Glass Layer
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      // Card Content
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Mürsal Sadiqov',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Image.network(
                                  'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/1280px-Mastercard-logo.svg.png',
                                  height: 35,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.credit_card, color: Colors.white),
                                ),
                              ],
                            ),
                            const Text(
                              '****   ****   ****   7852',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Etibarlılıq'.toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      '12/28',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'CVV'.toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      '***',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
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
              const SizedBox(height: 32),

              // Choose Payment Method horizontally
              Text('Choose Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 16),
               Row(
                children: [
                  Expanded(child: _paymentMethodChip(0, Icons.credit_card_rounded, label: 'Kart')),
                  const SizedBox(width: 12),
                  Expanded(child: _paymentMethodChip(1, Icons.paypal_rounded, color: const Color(0xFF003087), label: 'Paypal')),
                  const SizedBox(width: 12),
                  Expanded(child: _paymentMethodChip(3, Icons.wallet_rounded, color: const Color(0xFFFF9800), label: 'Cüzdan')),
                ],
              ),
              const SizedBox(height: 16),
              if (_selectedMethod == 2) ...[
                 SizedBox(
                   width: double.infinity,
                   height: 50,
                   child: ElevatedButton.icon(
                     onPressed: _processPayment,
                     icon: const Icon(Icons.apple, color: Colors.white),
                     label: const Text('Apple Pay ilə Ödə', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                     style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                   ),
                 ),
                 const SizedBox(height: 12),
                 SizedBox(
                   width: double.infinity,
                   height: 50,
                   child: ElevatedButton.icon(
                     onPressed: _processPayment,
                     icon: const Icon(Icons.g_mobiledata, color: Colors.white, size: 32),
                     label: const Text('Google Pay ilə Ödə', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                     style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4285F4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                   ),
                 ),
              ],
              const SizedBox(height: 16),

              // Schedule for Future
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Gələcək üçün planla', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      subtitle: Text('Sifarişin nə vaxt gəlməsini seçin', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      value: _isScheduled,
                      onChanged: (val) {
                        setState(() {
                          _isScheduled = val;
                          if (val && _scheduledDateTime == null) {
                            _scheduledDateTime = DateTime.now().add(const Duration(hours: 1));
                          }
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      activeColor: _accentColor,
                    ),
                    if (_isScheduled) ...[
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.access_time_filled),
                        title: Text(_scheduledDateTime != null 
                          ? DateFormat('dd MMM, HH:mm').format(_scheduledDateTime!) 
                          : 'Vaxt seçin'),
                        trailing: const Icon(Icons.edit_calendar),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _scheduledDateTime ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 7)),
                          );
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(_scheduledDateTime ?? DateTime.now()),
                            );
                            if (time != null) {
                              setState(() {
                                _scheduledDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                              });
                            }
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Promo Code
              Text('Promo Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    Icon(Icons.local_offer_outlined, color: Colors.grey.shade500, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _promoController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Promo kodunuz',
                          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cart.appliedCoupon != null ? Colors.green : Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                        child: Text(cart.appliedCoupon != null ? 'Tətbiq olundu' : 'Tətbiq et'),
                      ),
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

              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 8,
                    shadowColor: _accentColor.withOpacity(0.4),
                  ),
                  child: _isProcessing
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Ödənişi Tamamla', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            SizedBox(width: 12),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentMethodChip(int index, IconData icon, {Color? color, required String label}) {
    final isSelected = _selectedMethod == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? _accentColor : (isDark ? Colors.grey[900] : Colors.white),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? _accentColor : (isDark ? Colors.grey[800]! : Colors.grey.shade200),
            width: 1.5,
          ),
          boxShadow: isSelected 
              ? [BoxShadow(color: _accentColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))] 
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon, 
              color: isSelected ? Colors.white : (color ?? (isDark ? Colors.white70 : Colors.black54)),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
