import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'add_address_screen.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  void _removeAddress(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ünvanı sil?'),
        content: const Text('Bu ünvanı silmək istədiyinizə əminsiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Xeyr'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Bəli, sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final success = await auth.removeAddress(id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ünvan uğurla silindi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  IconData _getAddressIcon(String? title) {
    final t = (title ?? '').toLowerCase();
    if (t.contains('ev') || t.contains('home')) return Icons.home_rounded;
    if (t.contains('iş') || t.contains('work') || t.contains('ofis')) return Icons.work_rounded;
    return Icons.location_on_rounded;
  }

  Color _getAddressColor(String? title) {
    final t = (title ?? '').toLowerCase();
    if (t.contains('ev') || t.contains('home')) return const Color(0xFFFF5722);
    if (t.contains('iş') || t.contains('work') || t.contains('ofis')) return const Color(0xFF2196F3);
    return const Color(0xFF4CAF50);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    final addresses = user?['addresses'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Çatdırılma Ünvanları', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: addresses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.location_off_rounded, size: 60, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Hələ ünvan əlavə edilməyib',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Çatdırılma üçün ünvan əlavə edin',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddAddressScreen()),
                    ),
                    icon: const Icon(Icons.add_location_alt, color: Colors.white),
                    label: const Text('Ünvan Əlavə Et', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                final isDefault = address['isDefault'] == true;
                final icon = _getAddressIcon(address['title']);
                final color = _getAddressColor(address['title']);

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: isDefault ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // İkon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(icon, color: color, size: 28),
                        ),
                        const SizedBox(width: 16),
                        // Məlumat
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    address['title'] ?? 'Ünvan',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                  ),
                                  if (isDefault) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Əsas',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                address['address'] ?? '',
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${address['city'] ?? ''}, ${address['country'] ?? ''}',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                              ),
                              if ((address['postalCode'] ?? '').isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Poçt: ${address['postalCode']}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Sil düyməsi
                        IconButton(
                          onPressed: () => _removeAddress(address['_id']),
                          icon: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 22),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: addresses.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddAddressScreen()),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              icon: const Icon(Icons.add_location_alt, color: Colors.white),
              label: const Text('Yeni Ünvan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }
}
