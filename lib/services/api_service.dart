import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'https://ezanvakti.imsakiyem.com/api';
  static const String _cacheKeyPrefix = 'cached_prayer_times_';
  static const Map<String, String> _headers = {
    'Accept': 'application/json',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  };

  // Get countries list
  Future<List<Map<String, dynamic>>> getCountries() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/locations/countries'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> list = data['data'];
          return list.map((item) => {
            'id': item['_id'] as String,
            'name': item['name'] as String,
          }).toList();
        }
      }
      throw HttpException('Failed to load countries: ${response.statusCode} - ${response.body}');
    } catch (e) {
      // Fallback local list of common countries
      return [
        {'id': '2', 'name': 'TÜRKİYE'},
        {'id': '1', 'name': 'KUZEY KIBRIS'}
      ];
    }
  }

  // Get states (cities) under countryId
  Future<List<Map<String, dynamic>>> getStates(String countryId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/locations/states?countryId=$countryId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> list = data['data'];
        return list.map((item) => {
          'id': item['_id'] as String,
          'name': item['name'] as String,
        }).toList();
      }
    }
    throw HttpException('Failed to load cities: ${response.statusCode} - ${response.body}');
  }

  // Get districts under stateId
  Future<List<Map<String, dynamic>>> getDistricts(String stateId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/locations/districts?stateId=$stateId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> list = data['data'];
        return list.map((item) => {
          'id': item['_id'] as String,
          'name': item['name'] as String,
        }).toList();
      }
    }
    throw HttpException('Failed to load districts: ${response.statusCode} - ${response.body}');
  }

  // Get weekly prayer times for districtId, with offline caching support
  Future<List<Map<String, dynamic>>> getWeeklyPrayerTimes(String districtId) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_cacheKeyPrefix$districtId';

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/prayer-times/$districtId/weekly'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> rawList = data['data'];
          final List<Map<String, dynamic>> parsedList = rawList.map((item) {
            final times = item['times'] as Map<String, dynamic>;
            final dateStr = item['date'] as String;
            final hijri = item['hijri_date'] as Map<String, dynamic>;

            return {
              'date': dateStr, // e.g. "2026-05-27T00:00:00.000Z"
              'hijri_day': hijri['day'] as int,
              'hijri_month': hijri['month'] as int,
              'hijri_month_name': hijri['month_name'] as String,
              'hijri_year': hijri['year'] as int,
              'hijri_date_str': hijri['full_date'] as String,
              'imsak': times['imsak'] as String,
              'gunes': times['gunes'] as String,
              'ogle': times['ogle'] as String,
              'ikindi': times['ikindi'] as String,
              'aksam': times['aksam'] as String,
              'yatsi': times['yatsi'] as String,
            };
          }).toList();

          // Save to cache
          await prefs.setString(cacheKey, json.encode(parsedList));
          return parsedList;
        }
      }
      throw HttpException('Failed to load prayer times: ${response.statusCode} - ${response.body}');
    } catch (e) {
      // Load from cache if offline or error occurs
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final List<dynamic> decoded = json.decode(cachedData);
        return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      rethrow; // Rethrow if no cache is available
    }
  }
}
