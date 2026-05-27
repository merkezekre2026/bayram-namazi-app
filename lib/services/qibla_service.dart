import 'dart:math';
import '../constants/cities.dart';

class QiblaService {
  // Coordinates of Mecca (Kabe)
  static const double _meccaLat = 21.4225;
  static const double _meccaLon = 39.8262;

  // Calculates the direction of Qibla from North (0 to 360 degrees)
  double calculateAngle(double latitude, double longitude) {
    // Convert degrees to radians
    final double latRad = latitude * pi / 180.0;
    final double lonRad = longitude * pi / 180.0;
    final double meccaLatRad = _meccaLat * pi / 180.0;
    final double meccaLonRad = _meccaLon * pi / 180.0;

    final double deltaLon = meccaLonRad - lonRad;

    final double y = sin(deltaLon);
    final double x = cos(latRad) * tan(meccaLatRad) - sin(latRad) * cos(deltaLon);

    double qiblaAngle = atan2(y, x) * 180.0 / pi;
    
    // Normalize to 0-360 degrees
    qiblaAngle = (qiblaAngle + 360.0) % 360.0;
    return qiblaAngle;
  }

  // Get Qibla angle by city name (e.g. "ANKARA")
  double getAngleForCity(String cityName) {
    final searchName = cityName.trim().toUpperCase()
        .replaceAll('I', 'İ')
        .replaceAll('ı', 'I')
        .replaceAll('ç', 'Ç')
        .replaceAll('ğ', 'Ğ')
        .replaceAll('ö', 'Ö')
        .replaceAll('ş', 'Ş')
        .replaceAll('ü', 'Ü');

    final city = citiesList.firstWhere(
      (c) => c.name == searchName,
      orElse: () => citiesList.firstWhere((c) => c.name == 'ANKARA'), // Default fallback to Ankara
    );

    return calculateAngle(city.latitude, city.longitude);
  }
}
