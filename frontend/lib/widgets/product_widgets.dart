import 'package:flutter/material.dart';

/// Flash Sale geri sayım widget-i.
/// [endDate] — salonun bitmə tarixi. Rəng limit yaxınlaşdıqca qırmızıya keçir.
class FlashSaleCountdown extends StatefulWidget {
  final DateTime endDate;

  const FlashSaleCountdown({super.key, required this.endDate});

  @override
  State<FlashSaleCountdown> createState() => _FlashSaleCountdownState();
}

class _FlashSaleCountdownState extends State<FlashSaleCountdown> {
  late Duration _remaining;
  late Stream<Duration> _stream;

  @override
  void initState() {
    super.initState();
    _remaining = widget.endDate.difference(DateTime.now());
    _stream = Stream.periodic(const Duration(seconds: 1), (_) {
      return widget.endDate.difference(DateTime.now());
    });
  }

  String _format(Duration d) {
    if (d.isNegative) return '00:00:00';
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: _stream,
      initialData: _remaining,
      builder: (context, snapshot) {
        final d = snapshot.data ?? Duration.zero;
        final isUrgent = d.inMinutes < 30;
        final color = isUrgent ? Colors.red : Colors.orange;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_outlined, color: color, size: 14),
              const SizedBox(width: 4),
              Text(
                _format(d),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Nutrition bilgi kartı — məhsul detalı ekranında istifadə olunur.
class NutritionCard extends StatelessWidget {
  final Map<String, dynamic> nutrition;

  const NutritionCard({super.key, required this.nutrition});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final calories = nutrition['calories'] ?? 0;
    final protein = nutrition['protein'] ?? 0;
    final fat = nutrition['fat'] ?? 0;
    final carbs = nutrition['carbs'] ?? 0;

    if (calories == 0 && protein == 0 && fat == 0 && carbs == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_fire_department_outlined, color: Colors.orange),
              SizedBox(width: 8),
              Text('Qida dəyəri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutrient('Kaloriya', '$calories', 'kcal', Colors.orange, isDark),
              _buildNutrient('Protein', '$protein', 'q', Colors.blue, isDark),
              _buildNutrient('Yağ', '$fat', 'q', Colors.red, isDark),
              _buildNutrient('Karbohid.', '$carbs', 'q', Colors.green, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrient(String label, String value, String unit, Color color, bool isDark) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ),
        const SizedBox(height: 6),
        Text(unit, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black54)),
      ],
    );
  }
}
