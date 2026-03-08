import 'package:flutter/material.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Yardım və Dəstək', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Theme.of(context).colorScheme.primary.withOpacity(0.05),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Icon(Icons.support_agent_rounded, size: 80, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16),
                  Text('Necə kömək edə bilərik?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 8),
                  Text('Sualınız və ya probleminiz varsa bizimlə əlaqə saxlayın.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey)),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Əlaqə Vasitələri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 16),
                  _buildContactCard(context, Icons.phone_in_talk, 'Qaynar Xətt', '+994 12 345 67 89', isDark),
                  const SizedBox(height: 12),
                  _buildContactCard(context, Icons.email_outlined, 'Email Dəstəyi', 'support@kendly.az', isDark),
                  const SizedBox(height: 12),
                  _buildContactCard(context, Icons.chat_bubble_outline, 'Whatsapp', '+994 50 123 45 67', isDark),
                  
                  const SizedBox(height: 32),
                  Text('Tez-tez verilən suallar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 16),
                  
                  _buildFAQItem(context, 'Sifarişim gecikir, nə edim?', 'Sifarişiniz 45 dəqiqədən çox gecikibsə, dərhal Qaynar Xəttimizə zəng edərək kuryerin son statusunu öyrənə bilərsiniz.', isDark),
                  _buildFAQItem(context, 'Ödənişi qapıda edə bilərəm?', 'Bəli, sifariş zamanı nağd və ya qapıda post-terminal ilə ödəniş seçimini edə bilərsiniz.', isDark),
                  _buildFAQItem(context, 'Məhsulu necə geri qaytarım?', 'Qida təhlükəsizliyi qaydalarına əsasən bişmiş və gətirilmiş məhsullar yalnız yanlış və ya zədəli gəldikdə geri qaytarıla bilər.', isDark),
                  _buildFAQItem(context, 'Kart məlumatlarım təhlükəsizdir?', 'Bəli! Kart məlumatlarınız beynəlxalq PCI-DSS təhlükəsizlik standartlarına cavab verən sistemlərdə şifrələnərək saxlanılır.', isDark),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showMessageSheet(context, isDark);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.edit_document, color: Colors.white),
        label: const Text('Mesaj Yaz', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, IconData icon, String title, String subtitle, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Text(question, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
        iconColor: Theme.of(context).colorScheme.primary,
        collapsedIconColor: Colors.grey,
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        children: [
          Text(answer, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }

  void _showMessageSheet(BuildContext context, bool isDark) {
    final msgCtrl = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bizə Yazın', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 16),
              TextField(
                controller: msgCtrl,
                maxLines: 4,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Şikayət və ya təklifinizi buraya qeyd edin...',
                  hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (msgCtrl.text.trim().isNotEmpty) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mesajınız komandamıza göndərildi! ✅'), backgroundColor: Colors.green),
                      );
                    }
                  },
                  child: const Text('Göndər', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            ],
          ),
        );
      }
    );
  }
}
