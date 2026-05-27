import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/qibla_service.dart';
import '../constants/cities.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  final QiblaService _qiblaService = QiblaService();
  
  bool _isLoading = true;
  String _cityName = '';
  double _qiblaAngle = 0.0;
  double _lat = 0.0;
  double _lon = 0.0;

  @override
  void initState() {
    super.initState();
    _loadLocationAndQibla();
  }

  Future<void> _loadLocationAndQibla() async {
    final prefs = await SharedPreferences.getInstance();
    final stateName = prefs.getString('state_name') ?? 'ANKARA';

    // Normalise name
    final searchName = stateName.trim().toUpperCase()
        .replaceAll('I', 'İ')
        .replaceAll('ı', 'I')
        .replaceAll('ç', 'Ç')
        .replaceAll('ğ', 'Ğ')
        .replaceAll('ö', 'Ö')
        .replaceAll('ş', 'Ş')
        .replaceAll('ü', 'Ü');

    final city = citiesList.firstWhere(
      (c) => c.name == searchName,
      orElse: () => citiesList.firstWhere((c) => c.name == 'ANKARA'),
    );

    final angle = _qiblaService.calculateAngle(city.latitude, city.longitude);

    setState(() {
      _cityName = city.name;
      _lat = city.latitude;
      _lon = city.longitude;
      _qiblaAngle = angle;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KIBLE YÖNÜ'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD4AF37),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Selected City Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_city, color: Color(0xFFD4AF37)),
                              const SizedBox(width: 8),
                              Text(
                                _cityName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD4AF37),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enlem: ${_lat.toStringAsFixed(4)}° / Boylam: ${_lon.toStringAsFixed(4)}°',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Circular Compass Visualisation
                  Center(
                    child: SizedBox(
                      width: 260,
                      height: 260,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Compass Outer Dial Ring
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF0D2D23),
                              border: Border.all(
                                color: const Color(0xFFD4AF37),
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                          ),

                          // North (N) Indicator at Top
                          const Positioned(
                            top: 12,
                            child: Text(
                              'N',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          
                          // South (S) Indicator at Bottom
                          const Positioned(
                            bottom: 12,
                            child: Text(
                              'S',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white54,
                              ),
                            ),
                          ),

                          // West (W) Indicator at Left
                          const Positioned(
                            left: 14,
                            child: Text(
                              'W',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white54,
                              ),
                            ),
                          ),

                          // East (E) Indicator at Right
                          const Positioned(
                            right: 14,
                            child: Text(
                              'E',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white54,
                              ),
                            ),
                          ),

                          // Qibla Direction Needle / Arrow
                          Transform.rotate(
                            angle: _qiblaAngle * pi / 180.0,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Golden line pointing to Qibla
                                Container(
                                  width: 4,
                                  height: 180,
                                  color: Colors.transparent,
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    width: 4,
                                    height: 90,
                                    color: const Color(0xFFD4AF37),
                                  ),
                                ),
                                // Qibla Arrow Tip
                                Positioned(
                                  top: 10,
                                  child: Transform.rotate(
                                    angle: 0,
                                    child: const Icon(
                                      Icons.keyboard_double_arrow_up,
                                      color: Color(0xFFD4AF37),
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Center Hub Circle
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFD4AF37),
                            ),
                            child: const Icon(
                              Icons.star,
                              size: 14,
                              color: Color(0xFF071B15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Angle Display
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                      child: Column(
                        children: [
                          const Text(
                            'KIBLE AÇISI (KUZEYDEN)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_qiblaAngle.toStringAsFixed(1)}°',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Instruction Warning Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0x11D4AF37),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0x33D4AF37)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info, color: Color(0xFFD4AF37)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Cihazınızda pusula sensörü bulunmuyor veya tarayıcı izin vermiyorsa, cihazınızın üst kısmını fiziki bir pusula ile Kuzey (N) yönüne çevirin. Kadran üzerindeki altın renkli ok Kabe yönünü (Kıbleyi) gösterecektir.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
