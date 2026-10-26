import 'package:flutter/material.dart';
import '../../core/constants/app_icons.dart';
import '../../services/api/dashboard_api_service.dart';
import '../../services/local/cache_service.dart';

/// Represents a prayer schedule item for the prayer modal sheet.
class PrayerScheduleItem {
  final String name;
  final String time;
  final bool isNext;

  const PrayerScheduleItem({
    required this.name,
    required this.time,
    this.isNext = false,
  });
}

/// Represents a quick prayer time pill shown on the dashboard card.
class PrayerPill {
  final String name;
  final String time;
  final bool isHighlighted;

  const PrayerPill({
    required this.name,
    required this.time,
    this.isHighlighted = false,
  });
}

/// ViewModel for DashboardView following Provider MVVM architecture.
///
/// Integrates real data from:
/// - Open-Meteo Weather API
/// - Aladhan Prayer Times API
/// - ExchangeRate-API Currency Rates
class DashboardViewModel extends ChangeNotifier {
  final DashboardApiService _dashboardApiService;

  DashboardViewModel({DashboardApiService? dashboardApiService})
      : _dashboardApiService = dashboardApiService ?? DashboardApiService() {
    _hydrateFromCache();
    fetchAll();
  }

  static const String _keyWeatherCache = 'key_dashboard_weather_cache_v1';
  static const String _keyPrayerCache = 'key_dashboard_prayer_cache_v1';
  static const String _keyCurrencyCache = 'key_dashboard_currency_cache_v1';

  // ──────────────────────────────────────────────────────────────────────────
  // Location
  // ──────────────────────────────────────────────────────────────────────────
  String _selectedLocation = 'Madrid, Spain';

  final List<String> _availableLocations = const [
    'Madrid, Spain',
    'Barcelona, Spain',
    'Valencia, Spain',
    'Seville, Spain',
    'Malaga, Spain',
    'Bilbao, Spain',
    'Lahore, Pakistan',
    'Karachi, Pakistan',
    'Islamabad, Pakistan',
  ];

  static const Map<String, ({double lat, double lon, String city, String country})> _locationData = {
    'Madrid, Spain': (lat: 40.4168, lon: -3.7038, city: 'Madrid', country: 'Spain'),
    'Barcelona, Spain': (lat: 41.3851, lon: 2.1734, city: 'Barcelona', country: 'Spain'),
    'Valencia, Spain': (lat: 39.4699, lon: -0.3763, city: 'Valencia', country: 'Spain'),
    'Seville, Spain': (lat: 37.3891, lon: -5.9845, city: 'Seville', country: 'Spain'),
    'Malaga, Spain': (lat: 36.7213, lon: -4.4214, city: 'Malaga', country: 'Spain'),
    'Bilbao, Spain': (lat: 43.2630, lon: -2.9350, city: 'Bilbao', country: 'Spain'),
    'Lahore, Pakistan': (lat: 31.5204, lon: 74.3587, city: 'Lahore', country: 'Pakistan'),
    'Karachi, Pakistan': (lat: 24.8607, lon: 67.0011, city: 'Karachi', country: 'Pakistan'),
    'Islamabad, Pakistan': (lat: 33.6844, lon: 73.0479, city: 'Islamabad', country: 'Pakistan'),
  };

  String get selectedLocation => _selectedLocation;
  List<String> get availableLocations => _availableLocations;
  String get selectedCity => _selectedLocation.split(',').first.trim();

  void setSelectedLocation(String location) {
    if (_selectedLocation == location) return;
    _selectedLocation = location;
    notifyListeners();
    fetchWeather();
    fetchPrayerTimes();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Current Formatted Date
  // ──────────────────────────────────────────────────────────────────────────
  String get currentFormattedDate {
    final now = DateTime.now();
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Weather
  // ──────────────────────────────────────────────────────────────────────────
  String _weatherTemperature = '24°C';
  String _weatherCondition = 'Sunny';
  String _weatherHighLow = 'H: 28°C · L: 16°C';
  bool _isLoadingWeather = false;

  String get weatherTemperature => _weatherTemperature;
  String get weatherCondition => _weatherCondition;
  String get weatherHighLow => _weatherHighLow;
  bool get isLoadingWeather => _isLoadingWeather;

  Future<void> fetchWeather() async {
    _isLoadingWeather = true;
    notifyListeners();

    final locInfo = _locationData[_selectedLocation] ??
        (lat: 40.4168, lon: -3.7038, city: 'Madrid', country: 'Spain');

    final result = await _dashboardApiService.fetchWeather(
      latitude: locInfo.lat,
      longitude: locInfo.lon,
    );

    if (result != null) {
      _weatherTemperature = result['temperature'] as String? ?? _weatherTemperature;
      _weatherCondition = result['condition'] as String? ?? _weatherCondition;
      _weatherHighLow = result['highLow'] as String? ?? _weatherHighLow;

      _persistWeatherCache();
    }

    _isLoadingWeather = false;
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Currency Exchange
  // ──────────────────────────────────────────────────────────────────────────
  int _selectedCurrencyIndex = 0;
  bool _isLoadingCurrency = false;

  List<Map<String, String>> _currencies = [
    {
      'pair': 'EUR / PKR',
      'rate': '1 EUR = 310.45 PKR',
      'change': '↑ +1.35 (0.45%)',
      'positive': 'true',
    },
    {
      'pair': 'EUR / INR',
      'rate': '1 EUR = 108.36 INR',
      'change': '↑ +0.28 (0.31%)',
      'positive': 'true',
    },
    {
      'pair': 'EUR / BDT',
      'rate': '1 EUR = 137.73 BDT',
      'change': '↓ -0.15 (-0.11%)',
      'positive': 'false',
    },
  ];

  int get selectedCurrencyIndex => _selectedCurrencyIndex;
  List<Map<String, String>> get currencies => _currencies;
  Map<String, String> get currentCurrency => _currencies[_selectedCurrencyIndex];
  bool get isLoadingCurrency => _isLoadingCurrency;

  void nextCurrency() {
    _selectedCurrencyIndex = (_selectedCurrencyIndex + 1) % _currencies.length;
    notifyListeners();
  }

  void setCurrencyIndex(int index) {
    if (index >= 0 && index < _currencies.length) {
      _selectedCurrencyIndex = index;
      notifyListeners();
    }
  }

  Future<void> fetchExchangeRates() async {
    _isLoadingCurrency = true;
    notifyListeners();

    final rates = await _dashboardApiService.fetchExchangeRates(base: 'EUR');

    if (rates != null) {
      final pkrRate = rates['PKR'] ?? 310.45;
      final inrRate = rates['INR'] ?? 108.36;
      final bdtRate = rates['BDT'] ?? 137.73;

      _currencies = [
        {
          'pair': 'EUR / PKR',
          'rate': '1 EUR = ${pkrRate.toStringAsFixed(2)} PKR',
          'change': '↑ +1.35 (0.45%)',
          'positive': 'true',
        },
        {
          'pair': 'EUR / INR',
          'rate': '1 EUR = ${inrRate.toStringAsFixed(2)} INR',
          'change': '↑ +0.28 (0.31%)',
          'positive': 'true',
        },
        {
          'pair': 'EUR / BDT',
          'rate': '1 EUR = ${bdtRate.toStringAsFixed(2)} BDT',
          'change': '↓ -0.15 (-0.11%)',
          'positive': 'false',
        },
      ];

      _persistCurrencyCache();
    }

    _isLoadingCurrency = false;
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Prayer Times
  // ──────────────────────────────────────────────────────────────────────────
  bool _isLoadingPrayer = false;

  List<PrayerPill> _prayerPills = const [
    PrayerPill(name: 'Fajr', time: '05:45', isHighlighted: true),
    PrayerPill(name: 'Dhuhr', time: '14:10'),
    PrayerPill(name: 'Asr', time: '17:45'),
    PrayerPill(name: 'Maghrib', time: '21:05'),
    PrayerPill(name: 'Isha', time: '22:50'),
  ];

  List<PrayerScheduleItem> _prayerSchedule = const [
    PrayerScheduleItem(name: 'Fajr', time: '05:45 AM', isNext: true),
    PrayerScheduleItem(name: 'Sunrise', time: '06:45 AM'),
    PrayerScheduleItem(name: 'Dhuhr', time: '02:10 PM'),
    PrayerScheduleItem(name: 'Asr', time: '05:45 PM'),
    PrayerScheduleItem(name: 'Maghrib', time: '09:05 PM'),
    PrayerScheduleItem(name: 'Isha', time: '10:50 PM'),
  ];

  List<PrayerPill> get prayerPills => _prayerPills;
  List<PrayerScheduleItem> get prayerSchedule => _prayerSchedule;
  bool get isLoadingPrayer => _isLoadingPrayer;

  Future<void> fetchPrayerTimes() async {
    _isLoadingPrayer = true;
    notifyListeners();

    final locInfo = _locationData[_selectedLocation] ??
        (lat: 40.4168, lon: -3.7038, city: 'Madrid', country: 'Spain');

    final timings = await _dashboardApiService.fetchPrayerTimes(
      city: locInfo.city,
      country: locInfo.country,
      date: DateTime.now(),
    );

    if (timings != null) {
      final nextIdx = _determineNextPrayerIndex(timings);

      final fajr = timings['Fajr'] ?? '05:45';
      final sunrise = timings['Sunrise'] ?? '06:45';
      final dhuhr = timings['Dhuhr'] ?? '14:10';
      final asr = timings['Asr'] ?? '17:45';
      final maghrib = timings['Maghrib'] ?? '21:05';
      final isha = timings['Isha'] ?? '22:50';

      _prayerPills = [
        PrayerPill(name: 'Fajr', time: fajr, isHighlighted: nextIdx == 0),
        PrayerPill(name: 'Dhuhr', time: dhuhr, isHighlighted: nextIdx == 1),
        PrayerPill(name: 'Asr', time: asr, isHighlighted: nextIdx == 2),
        PrayerPill(name: 'Maghrib', time: maghrib, isHighlighted: nextIdx == 3),
        PrayerPill(name: 'Isha', time: isha, isHighlighted: nextIdx == 4),
      ];

      _prayerSchedule = [
        PrayerScheduleItem(name: 'Fajr', time: _formatTo12Hour(fajr), isNext: nextIdx == 0),
        PrayerScheduleItem(name: 'Sunrise', time: _formatTo12Hour(sunrise)),
        PrayerScheduleItem(name: 'Dhuhr', time: _formatTo12Hour(dhuhr), isNext: nextIdx == 1),
        PrayerScheduleItem(name: 'Asr', time: _formatTo12Hour(asr), isNext: nextIdx == 2),
        PrayerScheduleItem(name: 'Maghrib', time: _formatTo12Hour(maghrib), isNext: nextIdx == 3),
        PrayerScheduleItem(name: 'Isha', time: _formatTo12Hour(isha), isNext: nextIdx == 4),
      ];

      _persistPrayerCache();
    }

    _isLoadingPrayer = false;
    notifyListeners();
  }

  int _determineNextPrayerIndex(Map<String, String> timings) {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final prayerKeys = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    for (int i = 0; i < prayerKeys.length; i++) {
      final timeStr = timings[prayerKeys[i]];
      if (timeStr != null) {
        final parts = timeStr.split(':');
        if (parts.length >= 2) {
          final h = int.tryParse(parts[0]) ?? 0;
          final m = int.tryParse(parts[1]) ?? 0;
          final prayerMinutes = h * 60 + m;
          if (prayerMinutes > currentMinutes) {
            return i;
          }
        }
      }
    }
    return 0; // Next prayer is Fajr tomorrow
  }

  String _formatTo12Hour(String time24) {
    try {
      final parts = time24.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        final minute = parts[1].padLeft(2, '0');
        final period = hour >= 12 ? 'PM' : 'AM';
        if (hour == 0) {
          hour = 12;
        } else if (hour > 12) {
          hour -= 12;
        }
        return '${hour.toString().padLeft(2, '0')}:$minute $period';
      }
    } catch (_) {}
    return time24;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Cache Persistence & Hydration
  // ──────────────────────────────────────────────────────────────────────────
  void _hydrateFromCache() {
    try {
      if (!CacheService.isInitialized) return;

      final weatherJson = CacheService.instance.getJsonMap(_keyWeatherCache);
      if (weatherJson != null) {
        _weatherTemperature = weatherJson['temperature'] as String? ?? _weatherTemperature;
        _weatherCondition = weatherJson['condition'] as String? ?? _weatherCondition;
        _weatherHighLow = weatherJson['highLow'] as String? ?? _weatherHighLow;
      }

      final prayerJson = CacheService.instance.getJsonMap(_keyPrayerCache);
      if (prayerJson != null) {
        final pillsList = prayerJson['pills'] as List?;
        if (pillsList != null && pillsList.isNotEmpty) {
          _prayerPills = pillsList
              .map((p) => PrayerPill(
                    name: p['name'] as String? ?? '',
                    time: p['time'] as String? ?? '',
                    isHighlighted: p['isHighlighted'] as bool? ?? false,
                  ))
              .toList();
        }
        final scheduleList = prayerJson['schedule'] as List?;
        if (scheduleList != null && scheduleList.isNotEmpty) {
          _prayerSchedule = scheduleList
              .map((s) => PrayerScheduleItem(
                    name: s['name'] as String? ?? '',
                    time: s['time'] as String? ?? '',
                    isNext: s['isNext'] as bool? ?? false,
                  ))
              .toList();
        }
      }

      final currList = CacheService.instance.getJsonList(_keyCurrencyCache);
      if (currList != null && currList.isNotEmpty) {
        _currencies = currList
            .map((item) => item.map((k, v) => MapEntry(k, v.toString())))
            .toList();
      }
    } catch (e) {
      debugPrint('[DashboardViewModel] Cache hydration error: $e');
    }
  }

  void _persistWeatherCache() {
    try {
      if (!CacheService.isInitialized) return;
      CacheService.instance.saveJsonMap(_keyWeatherCache, {
        'temperature': _weatherTemperature,
        'condition': _weatherCondition,
        'highLow': _weatherHighLow,
      });
    } catch (_) {}
  }

  void _persistPrayerCache() {
    try {
      if (!CacheService.isInitialized) return;
      CacheService.instance.saveJsonMap(_keyPrayerCache, {
        'pills': _prayerPills
            .map((p) => {
                  'name': p.name,
                  'time': p.time,
                  'isHighlighted': p.isHighlighted,
                })
            .toList(),
        'schedule': _prayerSchedule
            .map((s) => {
                  'name': s.name,
                  'time': s.time,
                  'isNext': s.isNext,
                })
            .toList(),
      });
    } catch (_) {}
  }

  void _persistCurrencyCache() {
    try {
      if (!CacheService.isInitialized) return;
      CacheService.instance.saveJsonList(
        _keyCurrencyCache,
        _currencies.map((c) => Map<String, dynamic>.from(c)).toList(),
      );
    } catch (_) {}
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Emergency Services
  // ──────────────────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _emergencyServices = const [
    {
      'title': 'General Emergency (SOS)',
      'number': '112',
      'desc': 'All emergencies (Police, Ambulance, Fire)',
      'icon': AppIcons.callSvg,
      'color': Color(0xFFEF4444),
    },
    {
      'title': 'National Police (Policía Nacional)',
      'number': '091',
      'desc': 'Crime reports, security & emergencies',
      'icon': AppIcons.blockShieldSvg,
      'color': Color(0xFF2563EB),
    },
    {
      'title': 'Local Police (Policía Local)',
      'number': '092',
      'desc': 'Traffic accidents & municipal matters',
      'icon': AppIcons.shield,
      'color': Color(0xFF4F46E5),
    },
    {
      'title': 'Medical Emergency (Ambulancia)',
      'number': '061',
      'desc': 'Urgent health assistance & ambulance dispatch',
      'icon': AppIcons.callSvg,
      'color': Color(0xFF16A34A),
    },
    {
      'title': 'Firefighters (Bomberos)',
      'number': '080',
      'desc': 'Fires, rescue & hazardous situations',
      'icon': AppIcons.hotSvg,
      'color': Color(0xFFEA580C),
    },
  ];

  List<Map<String, dynamic>> get emergencyServices => _emergencyServices;

  // ──────────────────────────────────────────────────────────────────────────
  // Community Update
  // ──────────────────────────────────────────────────────────────────────────
  String get communityEventTitle => 'Eid Festival Event in $selectedCity';
  String get communityEventLocation => 'Parque del Retiro, $selectedCity';
  String get communityEventImageUrl =>
      'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&q=80&w=200';

  // ──────────────────────────────────────────────────────────────────────────
  // Fetch All & Refresh Dashboard
  // ──────────────────────────────────────────────────────────────────────────
  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  Future<void> fetchAll() async {
    await Future.wait([
      fetchWeather(),
      fetchPrayerTimes(),
      fetchExchangeRates(),
    ]);
  }

  Future<void> refreshDashboard() async {
    _isRefreshing = true;
    notifyListeners();

    await fetchAll();

    _isRefreshing = false;
    notifyListeners();
  }
}
