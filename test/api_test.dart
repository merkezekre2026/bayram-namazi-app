import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/services/api_service.dart';
import '../lib/services/qibla_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  group('Qibla Service Tests', () {
    final qiblaService = QiblaService();

    test('Calculate Qibla angle for Istanbul', () {
      // Istanbul coordinates: Lat 41.0082, Lon 28.9784
      final angle = qiblaService.calculateAngle(41.0082, 28.9784);
      print('Istanbul Qibla Angle: $angle');
      expect(angle, closeTo(151.6, 0.5));
    });

    test('Calculate Qibla angle for Ankara', () {
      // Ankara coordinates: Lat 39.9334, Lon 32.8597
      final angle = qiblaService.calculateAngle(39.9334, 32.8597);
      print('Ankara Qibla Angle: $angle');
      expect(angle, closeTo(160.2, 0.5));
    });

    test('Calculate Qibla angle for Izmir', () {
      // Izmir coordinates: Lat 38.4192, Lon 27.1287
      final angle = qiblaService.calculateAngle(38.4192, 27.1287);
      print('Izmir Qibla Angle: $angle');
      expect(angle, closeTo(143.7, 0.5));
    });
  });

  group('API Service Tests', () {
    final apiService = ApiService();

    test('Fetch countries list', () async {
      final countries = await apiService.getCountries();
      expect(countries, isNotEmpty);
      final hasTurkey = countries.any((c) => c['name'] == 'TÜRKİYE');
      expect(hasTurkey, isTrue);
    });

    test('Fetch states for Turkey', () async {
      // Turkey country ID is '2'
      final states = await apiService.getStates('2');
      expect(states, isNotEmpty);
      final hasAnkara = states.any((s) => s['name'] == 'ANKARA');
      expect(hasAnkara, isTrue);
    });

    test('Fetch districts for Ankara', () async {
      // Ankara state ID is '506'
      final districts = await apiService.getDistricts('506');
      expect(districts, isNotEmpty);
      final hasAnkaraDist = districts.any((d) => d['name'] == 'ANKARA');
      expect(hasAnkaraDist, isTrue);
    });

    test('Fetch weekly prayer times for Ankara center', () async {
      // Ankara center district ID is '9206'
      final weeklyTimes = await apiService.getWeeklyPrayerTimes('9206');
      expect(weeklyTimes, isNotEmpty);
      expect(weeklyTimes.length, greaterThanOrEqualTo(5));
      
      final firstDay = weeklyTimes.first;
      expect(firstDay.containsKey('imsak'), isTrue);
      expect(firstDay.containsKey('gunes'), isTrue);
      expect(firstDay.containsKey('hijri_date_str'), isTrue);
      print('Ankara Center First Day Imsak: ${firstDay['imsak']}, Hijri: ${firstDay['hijri_date_str']}');
    });
  });
}
