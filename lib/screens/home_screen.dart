import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = true;
  String? _errorMessage;
  
  String _districtName = '';
  String _stateName = '';
  String _districtId = '';

  List<Map<String, dynamic>> _weeklyTimes = [];
  Map<String, dynamic>? _todayTimes;
  
  Timer? _timer;
  String _currentTimeString = '';
  String _countdownString = '';

  @override
  void initState() {
    super.initState();
    _loadLocationAndTimes();
    _startClock();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startClock() {
    _currentTimeString = DateFormat('HH:mm:ss').format(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTimeString = DateFormat('HH:mm:ss').format(DateTime.now());
          _updateCountdown();
        });
      }
    });
  }

  Future<void> _loadLocationAndTimes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final distId = prefs.getString('district_id');
      final distName = prefs.getString('district_name') ?? '';
      final stName = prefs.getString('state_name') ?? '';

      if (distId == null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/location');
        }
        return;
      }

      setState(() {
        _districtId = distId;
        _districtName = distName;
        _stateName = stName;
      });

      final weekly = await _apiService.getWeeklyPrayerTimes(distId);
      
      // Find today's times
      final nowStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      Map<String, dynamic>? todayItem;
      for (final item in weekly) {
        final dateStr = item['date'] as String;
        if (dateStr.startsWith(nowStr)) {
          todayItem = item;
          break;
        }
      }

      // If not found, use first item as fallback
      todayItem ??= weekly.isNotEmpty ? weekly.first : null;

      setState(() {
        _weeklyTimes = weekly;
        _todayTimes = todayItem;
        _isLoading = false;
      });

      _updateCountdown();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Vakitler yüklenemedi. Lütfen internet bağlantınızı kontrol edip tekrar deneyin.';
      });
    }
  }

  // Calculate Eid Namaz time: Sunrise + 40 minutes
  String _calculateBayramNamazTime(String gunesTime) {
    if (gunesTime.isEmpty) return '06:00';
    try {
      final parts = gunesTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      final sunriseToday = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        hour,
        minute,
      );
      
      // Diyanet standard is approx Sunrise + 40 minutes
      final bayramTime = sunriseToday.add(const Duration(minutes: 40));
      return DateFormat('HH:mm').format(bayramTime);
    } catch (e) {
      return '06:00';
    }
  }

  void _updateCountdown() {
    if (_todayTimes == null) return;

    final now = DateTime.now();
    final isBayramDay = _isTodayBayram();
    
    if (isBayramDay) {
      // Countdown to today's Bayram Namazı
      final gunes = _todayTimes!['gunes'] as String;
      final bayramTimeStr = _calculateBayramNamazTime(gunes);
      final parts = bayramTimeStr.split(':');
      final bHour = int.parse(parts[0]);
      final bMin = int.parse(parts[1]);

      final bayramNamazDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        bHour,
        bMin,
      );

      if (now.isBefore(bayramNamazDateTime)) {
        final diff = bayramNamazDateTime.difference(now);
        final hours = diff.inHours.toString().padLeft(2, '0');
        final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
        final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
        _countdownString = 'Bayram Namazına Kalan Süre: $hours:$minutes:$seconds';
      } else {
        _countdownString = 'Bayram Namazı Kılındı. Bayramınız Mübarek Olsun!';
      }
    } else {
      // Countdown to next Bayram (e.g., Ramazan Bayramı 2027: March 9, 2027, or Kurban 2027: May 16, 2027)
      final todayDateOnly = DateTime(now.year, now.month, now.day);
      
      final List<Map<String, dynamic>> bayramDates = [
        {'name': 'Kurban Bayramı 2026', 'date': DateTime(2026, 5, 27)},
        {'name': 'Ramazan Bayramı 2027', 'date': DateTime(2027, 3, 9)},
        {'name': 'Kurban Bayramı 2027', 'date': DateTime(2027, 5, 16)},
      ];

      Map<String, dynamic>? nextB;
      for (final b in bayramDates) {
        final bDate = b['date'] as DateTime;
        if (!todayDateOnly.isAfter(bDate)) {
          nextB = b;
          break;
        }
      }

      if (nextB != null) {
        final bDate = nextB['date'] as DateTime;
        final diffDays = bDate.difference(todayDateOnly).inDays;
        
        if (diffDays == 0) {
          _countdownString = 'Bugün ${nextB['name']}!';
        } else {
          _countdownString = '${nextB['name']}\'na $diffDays Gün Kaldı';
        }
      } else {
        _countdownString = 'Gelecek bayram tarihleri hesaplanıyor...';
      }
    }
  }

  // Detects if today is an Eid day based on Hijri calendar returned by API
  // Ramazan Bayramı: 1 Şevval (Month 10)
  // Kurban Bayramı: 10 Zilhicce (Month 12)
  bool _isTodayBayram() {
    if (_todayTimes == null) return false;
    final day = _todayTimes!['hijri_day'] as int;
    final month = _todayTimes!['hijri_month'] as int;

    // Check for 1 Şevval (Ramazan Bayramı Day 1) or 10 Zilhicce (Kurban Bayramı Day 1)
    return (day == 1 && month == 10) || (day == 10 && month == 12);
  }

  String _getBayramTitle() {
    if (_todayTimes == null) return '';
    final day = _todayTimes!['hijri_day'] as int;
    final month = _todayTimes!['hijri_month'] as int;
    if (day == 1 && month == 10) return 'Ramazan Bayramınız Mübarek Olsun';
    if (day == 10 && month == 12) return 'Kurban Bayramınız Mübarek Olsun';
    return '';
  }

  // Highlight next prayer time
  String _getNextPrayerName() {
    if (_todayTimes == null) return '';
    final now = DateTime.now();
    final timeFormat = DateFormat('HH:mm');
    
    final prayers = ['imsak', 'gunes', 'ogle', 'ikindi', 'aksam', 'yatsi'];
    for (final prayer in prayers) {
      final pTimeStr = _todayTimes![prayer] as String;
      final parts = pTimeStr.split(':');
      final pTime = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
      
      if (now.isBefore(pTime)) {
        return prayer;
      }
    }
    return 'imsak'; // If past Isha, next is Fajr/Imsak tomorrow
  }

  @override
  Widget build(BuildContext context) {
    final nextPrayer = _getNextPrayerName();
    final isBayram = _isTodayBayram();
    
    final String formattedDate = DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(DateTime.now());
    final String hijriStr = _todayTimes != null ? _todayTimes!['hijri_date_str'] as String : '';

    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD4AF37),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadLocationAndTimes,
              color: const Color(0xFFD4AF37),
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  // Upper Gradient Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0F4C3A), Color(0xFF071B15)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on, color: Color(0xFFD4AF37), size: 20),
                            const SizedBox(width: 6),
                            Text(
                              '$_stateName / $_districtName'.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4AF37),
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        if (hijriStr.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            hijriStr,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFFA5B4FC), // Indigo hint
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Text(
                          _currentTimeString,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0x33FF0000),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red, width: 0.5),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Bayram Namazı Vakti / Geri Sayım Kartı
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Icon(
                                  isBayram ? Icons.star_border : Icons.alarm,
                                  color: const Color(0xFFD4AF37),
                                  size: 40,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  isBayram ? 'BAYRAM NAMAZI VAKTİ' : 'BAYRAM GERİ SAYIM',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (isBayram && _todayTimes != null) ...[
                                  Text(
                                    _calculateBayramNamazTime(_todayTimes!['gunes'] as String),
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFD4AF37),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _getBayramTitle(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Güneş doğuşundan 40 dakika sonra kılınır.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white60,
                                    ),
                                  ),
                                ] else ...[
                                  Text(
                                    _countdownString,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),

                        // Ezan Vakitleri Kartı
                        if (_todayTimes != null) ...[
                          const Text(
                            'GÜNLÜK EZAN VAKİTLERİ',
                            style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                              child: Column(
                                children: [
                                  _buildPrayerRow('İmsak', _todayTimes!['imsak'] as String, nextPrayer == 'imsak'),
                                  _buildPrayerRow('Güneş (Doğuş)', _todayTimes!['gunes'] as String, nextPrayer == 'gunes'),
                                  _buildPrayerRow('Öğle', _todayTimes!['ogle'] as String, nextPrayer == 'ogle'),
                                  _buildPrayerRow('İkindi', _todayTimes!['ikindi'] as String, nextPrayer == 'ikindi'),
                                  _buildPrayerRow('Akşam (İftar)', _todayTimes!['aksam'] as String, nextPrayer == 'aksam'),
                                  _buildPrayerRow('Yatsı', _todayTimes!['yatsi'] as String, nextPrayer == 'yatsi'),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Hızlı Erişim Menüsü Grid
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          children: [
                            _buildMenuButton(
                              icon: Icons.book,
                              label: 'Kılavuz',
                              sub: 'Nasıl Kılınır?',
                              onTap: () => Navigator.pushNamed(context, '/guide'),
                            ),
                            _buildMenuButton(
                              icon: Icons.explore,
                              label: 'Kıble',
                              sub: 'Yön Bulucu',
                              onTap: () => Navigator.pushNamed(context, '/qibla'),
                            ),
                            _buildMenuButton(
                              icon: Icons.settings,
                              label: 'Konum',
                              sub: 'Şehir Seç',
                              onTap: () => Navigator.pushNamed(context, '/location'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPrayerRow(String label, String time, bool isNext) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isNext ? const Color(0x22D4AF37) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isNext ? Border.all(color: const Color(0xFFD4AF37), width: 1) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.between,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
              color: isNext ? const Color(0xFFD4AF37) : Colors.white,
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isNext ? const Color(0xFFD4AF37) : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required String sub,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0D2D23),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x33D4AF37)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFD4AF37), size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white60,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
