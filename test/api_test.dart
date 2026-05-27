import 'package:flutter_test/flutter_test.dart';
import '../lib/services/qibla_service.dart';

void main() {
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
}
