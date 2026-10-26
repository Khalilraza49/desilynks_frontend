import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_endpoints.dart';

class DashboardApiService {
  final http.Client _client;

  DashboardApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches weather from Open-Meteo (or OpenWeatherMap as fallback)
  Future<Map<String, dynamic>?> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final baseUri = ApiEndpoints.openMeteoUrl;
      final uri = Uri.parse(
        '$baseUri?latitude=$latitude&longitude=$longitude'
        '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m'
        '&daily=temperature_2m_max,temperature_2m_min&timezone=auto',
      );

      final response = await _client.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final current = data['current'] as Map<String, dynamic>?;
        final daily = data['daily'] as Map<String, dynamic>?;

        if (current != null) {
          final tempNum = (current['temperature_2m'] as num?)?.toDouble() ?? 24.0;
          final weatherCode = (current['weather_code'] as num?)?.toInt() ?? 0;
          final condition = _mapWeatherCodeToCondition(weatherCode);

          double maxTemp = tempNum + 4;
          double minTemp = tempNum - 6;
          if (daily != null) {
            final maxList = daily['temperature_2m_max'] as List?;
            final minList = daily['temperature_2m_min'] as List?;
            if (maxList != null && maxList.isNotEmpty) {
              maxTemp = (maxList.first as num).toDouble();
            }
            if (minList != null && minList.isNotEmpty) {
              minTemp = (minList.first as num).toDouble();
            }
          }

          return {
            'temperature': '${tempNum.round()}°C',
            'condition': condition,
            'highLow': 'H: ${maxTemp.round()}°C · L: ${minTemp.round()}°C',
            'weatherCode': weatherCode,
          };
        }
      }
    } catch (e) {
      debugPrint('[DashboardApiService] Open-Meteo weather fetch error: $e');
    }

    // Fallback: If OpenWeatherMap API key is provided
    if (ApiEndpoints.openWeatherMapApiKey.isNotEmpty &&
        ApiEndpoints.openWeatherMapApiKey != 'YOUR_API_KEY') {
      try {
        final uri = Uri.parse(
          '${ApiEndpoints.openWeatherMapUrl}?lat=$latitude&lon=$longitude'
          '&appid=${ApiEndpoints.openWeatherMapApiKey}&units=metric',
        );
        final response = await _client.get(uri).timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final main = data['main'] as Map<String, dynamic>?;
          final weatherList = data['weather'] as List?;
          final condition = (weatherList != null && weatherList.isNotEmpty)
              ? weatherList.first['main'] as String? ?? 'Sunny'
              : 'Sunny';
          final temp = (main?['temp'] as num?)?.toDouble() ?? 24.0;
          final maxTemp = (main?['temp_max'] as num?)?.toDouble() ?? temp + 3;
          final minTemp = (main?['temp_min'] as num?)?.toDouble() ?? temp - 5;

          return {
            'temperature': '${temp.round()}°C',
            'condition': condition,
            'highLow': 'H: ${maxTemp.round()}°C · L: ${minTemp.round()}°C',
            'weatherCode': 0,
          };
        }
      } catch (e) {
        debugPrint('[DashboardApiService] OpenWeatherMap fallback error: $e');
      }
    }

    return null;
  }

  /// Fetches prayer times from Aladhan API
  Future<Map<String, String>?> fetchPrayerTimes({
    required String city,
    required String country,
    required DateTime date,
  }) async {
    try {
      final formattedDate =
          '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';

      final cleanCity = Uri.encodeComponent(city);
      final cleanCountry = Uri.encodeComponent(country);
      final uri = Uri.parse(
        '${ApiEndpoints.aladhanUrl}/$formattedDate?city=$cleanCity&country=$cleanCountry&method=1&school=1',
      );

      final response = await _client.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final data = decoded['data'] as Map<String, dynamic>?;
        final timings = data?['timings'] as Map<String, dynamic>?;

        if (timings != null) {
          return {
            'Fajr': _cleanTiming(timings['Fajr']),
            'Sunrise': _cleanTiming(timings['Sunrise']),
            'Dhuhr': _cleanTiming(timings['Dhuhr']),
            'Asr': _cleanTiming(timings['Asr']),
            'Maghrib': _cleanTiming(timings['Maghrib']),
            'Isha': _cleanTiming(timings['Isha']),
          };
        }
      }
    } catch (e) {
      debugPrint('[DashboardApiService] Aladhan prayer times error: $e');
    }
    return null;
  }

  /// Fetches real-time exchange rates from ExchangeRate-API
  Future<Map<String, double>?> fetchExchangeRates({String base = 'EUR'}) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.exchangeRateUrl}/$base');
      final response = await _client.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final rates = decoded['rates'] as Map<String, dynamic>?;

        if (rates != null) {
          final Map<String, double> result = {};
          rates.forEach((key, value) {
            if (value is num) {
              result[key] = value.toDouble();
            }
          }          );
          return result;
        }
      }
    } catch (e) {
      debugPrint('[DashboardApiService] ExchangeRate API error: $e');
    }
    return null;
  }

  String _cleanTiming(dynamic raw) {
    if (raw == null) return '00:00';
    final str = raw.toString().trim();
    // Sometimes returns "04:41 (PKT)" -> extract "04:41"
    final spaceIdx = str.indexOf(' ');
    if (spaceIdx != -1) {
      return str.substring(0, spaceIdx);
    }
    return str;
  }

  String _mapWeatherCodeToCondition(int code) {
    switch (code) {
      case 0:
        return 'Sunny';
      case 1:
        return 'Mainly Clear';
      case 2:
        return 'Partly Cloudy';
      case 3:
        return 'Overcast';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rainy';
      case 71:
      case 73:
      case 75:
        return 'Snowy';
      case 80:
      case 81:
      case 82:
        return 'Showers';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorm';
      default:
        return 'Sunny';
    }
  }
}
