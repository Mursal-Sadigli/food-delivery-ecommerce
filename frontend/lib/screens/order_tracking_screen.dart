import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:lottie/lottie.dart' hide Marker;
import 'package:latlong2/latlong.dart';
import 'main_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> with TickerProviderStateMixin {
  int _currentStep = 0;
  Timer? _timer;
  
  // Real Maps variables
  final MapController _mapController = MapController();
  final LatLng _restaurantLocation = const LatLng(40.4093, 49.8671); // Baku
  final LatLng _homeLocation = const LatLng(40.3800, 49.8500); // Baku target
  LatLng _currentCourierLocation = const LatLng(40.4093, 49.8671);
  
  late AnimationController _pulseController;
  
  final List<Map<String, dynamic>> _steps = [
    {'title': 'Sifariş qəbul edildi', 'subtitle': 'Restoranınız sifarişi qəbul etdi', 'icon': Icons.receipt_long, 'time': '12:30'},
    {'title': 'Hazırlanır', 'subtitle': 'Yeməyiniz hazırlanır 🍳', 'icon': Icons.restaurant, 'time': '12:35'},
    {'title': 'Kuryerə verildi', 'subtitle': 'Kuryer yeməyi aldı', 'icon': Icons.delivery_dining, 'time': '12:50'},
    {'title': 'Yoldadır', 'subtitle': 'Kuryer sizə tərəf gəlir 🛵', 'icon': Icons.directions_bike, 'time': '12:55'},
    {'title': 'Çatdırıldı', 'subtitle': 'Nuş olsun! 🎉', 'icon': Icons.check_circle, 'time': '13:10'},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    // Kuryer hərəkət simulyasiyası (hər saniyədə yeri dəyişir)
    final totalSteps = 15;
    int currentMoveStep = 0;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentMoveStep < totalSteps) {
        currentMoveStep++;
        
        final progress = currentMoveStep / totalSteps;
        final newLat = _restaurantLocation.latitude + (_homeLocation.latitude - _restaurantLocation.latitude) * progress;
        final newLng = _restaurantLocation.longitude + (_homeLocation.longitude - _restaurantLocation.longitude) * progress;
        
        if (mounted) {
          setState(() {
            _currentCourierLocation = LatLng(newLat, newLng);
            
            // Addımları da simulyasiya edirik (hər 3 saniyədə bir)
            if (currentMoveStep % 3 == 0 && _currentStep < _steps.length - 1) {
              _currentStep++;
            }
          });
        }
      } else {
        if (mounted) setState(() => _currentStep = _steps.length - 1);
        timer.cancel();
      }
    });

    // Xəritə mərkəzləşdirilməsi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          final bounds = LatLngBounds.fromPoints([_restaurantLocation, _homeLocation]);
          _mapController.fitCamera(CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(50),
          ));
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Sifarişi İzlə', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: CustomScrollView(
        slivers: [
          // ── Real Flutter Map sahəsi ──
          SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
              width: double.infinity,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _restaurantLocation,
                      initialZoom: 13,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.ecommerce',
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [_restaurantLocation, _homeLocation],
                            strokeWidth: 4.0,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                            isDotted: true,
                          ),
                          Polyline(
                            points: [_restaurantLocation, _currentCourierLocation],
                            strokeWidth: 5.0,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          // Restoran
                          Marker(
                            point: _restaurantLocation,
                            width: 30,
                            height: 30,
                            child: Container(
                              decoration: BoxDecoration(color: Colors.green.shade600, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                              child: const Icon(Icons.restaurant, color: Colors.white, size: 16),
                            ),
                          ),
                          // Ev
                          Marker(
                            point: _homeLocation,
                            width: 30,
                            height: 30,
                            child: Container(
                              decoration: BoxDecoration(color: Colors.red.shade600, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                              child: const Icon(Icons.home, color: Colors.white, size: 16),
                            ),
                          ),
                          // Kuryer
                          Marker(
                            point: _currentCourierLocation,
                            width: 50,
                            height: 50,
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Lottie.network(
                                  'https://assets5.lottiefiles.com/packages/lf20_m6vumqsv.json', // Delivery Courier
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.contain,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Təxmini vaxt badgesi
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer, size: 18, color: Colors.orange),
                            const SizedBox(width: 8),
                            Text(
                              _currentStep >= _steps.length - 1 ? 'Çatdırıldı!' : 'Təxmini: ${25 - _currentStep * 5} dəq',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Kuryer məlumatları ──
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kuryer Əli', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('⭐ 4.9 · 500+ çatdırılma', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.phone, color: Colors.green.shade600, size: 22),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.chat_bubble_outline, color: Colors.blue.shade600, size: 22),
                  ),
                ],
              ),
            ),
          ),

          // ── Proqress addımları ──
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.history, size: 20, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'Sifariş Tarixçəsi',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(_steps.length, (index) {
                    final step = _steps[index];
                    final isCompleted = index <= _currentStep;
                    final isActive = index == _currentStep;
                    final isLast = index == _steps.length - 1;

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Timeline
                          Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                  boxShadow: isCompleted ? [
                                    BoxShadow(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ] : null,
                                ),
                                child: Icon(
                                  step['icon'] as IconData,
                                  size: 18,
                                  color: isCompleted ? Colors.white : Colors.grey.shade400,
                                ),
                              ),
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    width: 3,
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isCompleted ? Theme.of(context).colorScheme.primary : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          // Mətn hissəsi
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: isLast ? 0 : 28),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        step['title'] as String,
                                        style: TextStyle(
                                          fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                                          fontSize: 15,
                                          color: isCompleted ? Colors.black : Colors.grey.shade400,
                                        ),
                                      ),
                                      if (isCompleted)
                                        Text(
                                          step['time'] as String,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    step['subtitle'] as String,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isCompleted ? Colors.grey.shade600 : Colors.grey.shade300,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          
          SliverToBoxAdapter(child: const SizedBox(height: 20)),

          // Ana səhifə düyməsi
          if (_currentStep >= _steps.length - 1)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const MainScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Ana Səhifəyə Qayıt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
            ),
          
          SliverToBoxAdapter(child: const SizedBox(height: 30)),
        ],
      ),
    );
  }
}
