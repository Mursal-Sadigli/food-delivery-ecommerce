import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/auth_provider.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _postalCodeCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'Azərbaycan');
  final _noteCtrl = TextEditingController();
  
  String _selectedType = 'Ev';
  bool _isDefault = false;
  bool _isSaving = false;

  final MapController _mapController = MapController();
  LatLng _centerLocation = const LatLng(40.4093, 49.8671); // Default Baku

  final List<Map<String, dynamic>> _addressTypes = [
    {'label': 'Ev', 'icon': Icons.home_rounded, 'color': const Color(0xFFFF5722)},
    {'label': 'İş', 'icon': Icons.work_rounded, 'color': const Color(0xFF2196F3)},
    {'label': 'Digər', 'icon': Icons.location_on_rounded, 'color': const Color(0xFF4CAF50)},
  ];

  void _saveAddress() async {
    if (_addressCtrl.text.isEmpty || _cityCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ünvan və şəhər sahələri mütləqdir'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.addAddress({
      'title': _selectedType,
      'address': _addressCtrl.text,
      'city': _cityCtrl.text,
      'postalCode': _postalCodeCtrl.text,
      'country': _countryCtrl.text,
      'isDefault': _isDefault,
    });

    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ünvan uğurla əlavə edildi ✅'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xəta baş verdi. Yenidən cəhd edin.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _postalCodeCtrl.dispose();
    _countryCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Yeni Ünvan', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Real Xəritə sahəsi ──
            SizedBox(
              height: 250,
              width: double.infinity,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _centerLocation,
                      initialZoom: 14.0,
                      onPositionChanged: (position, hasGesture) {
                        if (hasGesture && position.center != null) {
                          setState(() {
                            _centerLocation = position.center!;
                          });
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.ecommerce',
                      ),
                    ],
                  ),
                  
                  // Mərkəzdə Pin ikonu (harada olduğumuzu göstərir)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 30), // Yuxan pin offseti
                      child: Icon(Icons.location_on, size: 40, color: Colors.red),
                    ),
                  ),
                  
                  // Koordinatlar info qutusu
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.1), blurRadius: 10)],
                        ),
                        child: Text(
                          '${_centerLocation.latitude.toStringAsFixed(4)}, ${_centerLocation.longitude.toStringAsFixed(4)}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ),
                  ),

                  // Cari yer düyməsi
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: GestureDetector(
                      onTap: () {
                        final curr = const LatLng(40.4093, 49.8671);
                        setState(() => _centerLocation = curr);
                        _mapController.move(curr, 14.0);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('📍 Cari yerə qayıdıldı'), duration: Duration(seconds: 1)),
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.1), blurRadius: 10)],
                        ),
                        child: Icon(Icons.my_location, color: isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Form ──
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ünvan növü', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                  const SizedBox(height: 12),
                  Row(
                    children: _addressTypes.map((type) {
                      final isSelected = _selectedType == type['label'];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedType = type['label']),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? (type['color'] as Color).withOpacity(0.1) : (isDark ? Colors.grey[800] : Colors.white),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? type['color'] as Color : (isDark ? Colors.grey[700]! : Colors.grey.shade200),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(type['icon'] as IconData, color: isSelected ? type['color'] as Color : (isDark ? Colors.white70 : Colors.grey), size: 28),
                                const SizedBox(height: 6),
                                Text(
                                  type['label'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? type['color'] as Color : (isDark ? Colors.white70 : Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  _buildField(label: 'Tam ünvan', hint: 'Küçə, bina, mənzil nömrəsi', controller: _addressCtrl, icon: Icons.location_on_outlined),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(flex: 2, child: _buildField(label: 'Şəhər', hint: 'Bakı', controller: _cityCtrl, icon: Icons.location_city)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildField(label: 'Poçt', hint: 'AZ1000', controller: _postalCodeCtrl, icon: Icons.mail_outline)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildField(label: 'Ölkə', hint: 'Azərbaycan', controller: _countryCtrl, icon: Icons.flag_outlined),
                  const SizedBox(height: 16),

                  _buildField(label: 'Əlavə qeyd (isteğe bağlı)', hint: 'Məs: 3-cü mərtəbə', controller: _noteCtrl, icon: Icons.note_alt_outlined, maxLines: 2),
                  const SizedBox(height: 16),

                  // Əsas ünvan toggle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              const Icon(Icons.star_outline, color: Colors.amber, size: 22),
                              const SizedBox(width: 10),
                              Flexible(child: Text('Əsas ünvan olaraq təyin et', style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black))),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isDefault,
                          onChanged: (v) => setState(() => _isDefault = v),
                          activeColor: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Ünvanı Saxla', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({required String label, required String hint, required TextEditingController controller, required IconData icon, int maxLines = 1}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
            prefixIcon: Icon(icon, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500, size: 20),
            filled: true,
            fillColor: isDark ? Colors.grey[800] : Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)),
          ),
        ),
      ],
    );
  }
}
