import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:desilynks/models/property_model.dart';
import 'package:desilynks/models/job_model.dart';
import 'package:desilynks/models/worker_profile_model.dart';
import 'package:desilynks/models/search_result_model.dart';

void main() {
  const baseUrl = 'https://dev.desilynks.com';

  setUpAll(() async {
    await dotenv.load(fileName: '.env');
  });

  group('Manual & Integration Testing for Search Endpoints', () {
    test('1. GET /search/properties returns 200 and parses into PropertyModel', () async {
      final uri = Uri.parse('$baseUrl/search/properties');
      final res = await http.get(uri);
      expect(res.statusCode, equals(200));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      expect(body.containsKey('data'), isTrue);
      expect(body['data'], isA<List>());

      final list = (body['data'] as List)
          .map((item) => PropertyModel.fromJson(item as Map<String, dynamic>))
          .toList();

      expect(list.isNotEmpty, isTrue);
      final hasRoom = list.any((p) => p.type.toUpperCase() == 'ROOM');
      expect(hasRoom, isTrue);

      final meta = SearchMeta.fromJson(body['meta'] as Map<String, dynamic>);
      expect(meta.total, greaterThanOrEqualTo(list.length));
    });

    test('2. GET /search/properties?type=ROOM returns only Room listings', () async {
      final uri = Uri.parse('$baseUrl/search/properties?type=ROOM');
      final res = await http.get(uri);
      expect(res.statusCode, equals(200));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final list = (body['data'] as List)
          .map((item) => PropertyModel.fromJson(item as Map<String, dynamic>))
          .toList();

      expect(list.isNotEmpty, isTrue);
      for (final p in list) {
        expect(p.type.toUpperCase(), equals('ROOM'));
      }
    });

    test('3. GET /search/properties?type=APARTMENT returns valid response for Apartments', () async {
      final uri = Uri.parse('$baseUrl/search/properties?type=APARTMENT');
      final res = await http.get(uri);
      expect(res.statusCode, equals(200));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      expect(body['data'], isA<List>());
      final list = (body['data'] as List)
          .map((item) => PropertyModel.fromJson(item as Map<String, dynamic>))
          .toList();

      expect(list, isA<List<PropertyModel>>());
    });

    test('4. GET /search/jobs returns 200 and parses into JobModel', () async {
      final uri = Uri.parse('$baseUrl/search/jobs');
      final res = await http.get(uri);
      expect(res.statusCode, equals(200));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      expect(body['data'], isA<List>());

      final list = (body['data'] as List)
          .map((item) => JobModel.fromJson(item as Map<String, dynamic>))
          .toList();

      expect(list.isNotEmpty, isTrue);
      expect(list.first.title.isNotEmpty, isTrue);
    });

    test('5. GET /search/worker-profiles returns 200 and parses into WorkerProfileModel', () async {
      final uri = Uri.parse('$baseUrl/search/worker-profiles');
      final res = await http.get(uri);
      expect(res.statusCode, equals(200));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      expect(body['data'], isA<List>());

      final list = (body['data'] as List)
          .map((item) => WorkerProfileModel.fromJson(item as Map<String, dynamic>))
          .toList();

      expect(list.isNotEmpty, isTrue);
      expect(list.first.profession.isNotEmpty, isTrue);
      expect(list.first.service.isNotEmpty, isTrue);
    });

    test('6. GET /search/suggest returns autocomplete suggestions', () async {
      final uri = Uri.parse('$baseUrl/search/suggest?query=Room&index=properties');
      final res = await http.get(uri);
      expect(res.statusCode, equals(200));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      expect(body['suggestions'], isA<List>());
      final suggestions = (body['suggestions'] as List).cast<String>();
      expect(suggestions.isNotEmpty, isTrue);
    });
  });
}
