import 'dart:convert';

import 'package:flutter_app_test_stacked/services/network_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_test_stacked/app/app.locator.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  final client = MockClient();
  httpClient = client;
  const url = 'test';
  final uri = Uri.parse('${NetworkService.baseUrl}/$url?');

  Object getBody([Map<String, dynamic> body = const {}]) {
    return json.encode(body);
  }

  group('NetworkService Tests -', () {
    setUp(setUpServices);

    tearDown(tearDownServices);

    group('GET -', () {
      test('should call correctly', () async {
        final networkService = locator<NetworkService>();

        when(
          client.get(
            uri,
            headers: NetworkService.headers,
          ),
        ).thenAnswer((_) async {
          return http.Response('bodyTest', 200);
        });

        final response = await networkService.get(url);

        expect(response.statusCode, StatusCode.ok);
        expect(response.body, 'bodyTest');
      });

      test('should call correctly with params', () async {
        final networkService = locator<NetworkService>();

        const params = {'a': 'b'};

        when(
          client.get(
            Uri.parse(
              '${NetworkService.baseUrl}/$url?'
              '${Uri(queryParameters: params).query}',
            ),
            headers: NetworkService.headers,
          ),
        ).thenAnswer((_) async {
          return http.Response('bodyTest', 200);
        });

        final response = await networkService.get(url, params: params);

        expect(response.statusCode, StatusCode.ok);
        expect(response.body, 'bodyTest');
      });
    });

    group('POST -', () {
      test('should call correctly', () async {
        final networkService = locator<NetworkService>();

        when(
          client.post(
            uri,
            headers: NetworkService.headers,
            encoding: NetworkService.encoding,
            body: getBody(),
          ),
        ).thenAnswer((_) async {
          return http.Response('bodyTest', 200);
        });

        final response = await networkService.post(url);

        expect(response.statusCode, StatusCode.ok);
        expect(response.body, 'bodyTest');
      });

      test('should call correctly with body', () async {
        final networkService = locator<NetworkService>();

        const body = {'a': 'b'};

        when(
          client.post(
            uri,
            headers: NetworkService.headers,
            encoding: NetworkService.encoding,
            body: getBody(body),
          ),
        ).thenAnswer((_) async {
          return http.Response('bodyTest', 200);
        });

        final response = await networkService.post(url, body: body);

        expect(response.statusCode, StatusCode.ok);
        expect(response.body, 'bodyTest');
      });
    });

    group('PUT -', () {
      test('should call correctly', () async {
        final networkService = locator<NetworkService>();

        when(
          client.put(
            uri,
            headers: NetworkService.headers,
            encoding: NetworkService.encoding,
            body: getBody(),
          ),
        ).thenAnswer((_) async {
          return http.Response('bodyTest', 200);
        });

        final response = await networkService.put(url);

        expect(response.statusCode, StatusCode.ok);
        expect(response.body, 'bodyTest');
      });

      test('should call correctly with body', () async {
        final networkService = locator<NetworkService>();

        const body = {'a': 'b'};

        when(
          client.put(
            uri,
            headers: NetworkService.headers,
            encoding: NetworkService.encoding,
            body: getBody(body),
          ),
        ).thenAnswer((_) async {
          return http.Response('bodyTest', 200);
        });

        final response = await networkService.put(url, body: body);

        expect(response.statusCode, StatusCode.ok);
        expect(response.body, 'bodyTest');
      });
    });

    group('PATCH -', () {
      test('should call correctly', () async {
        final networkService = locator<NetworkService>();

        when(
          client.patch(
            uri,
            headers: NetworkService.headers,
            encoding: NetworkService.encoding,
            body: getBody(),
          ),
        ).thenAnswer((_) async {
          return http.Response('bodyTest', 200);
        });

        final response = await networkService.patch(url);

        expect(response.statusCode, StatusCode.ok);
        expect(response.body, 'bodyTest');
      });

      test('should call correctly with body', () async {
        final networkService = locator<NetworkService>();

        const body = {'a': 'b'};

        when(
          client.patch(
            uri,
            headers: NetworkService.headers,
            encoding: NetworkService.encoding,
            body: getBody(body),
          ),
        ).thenAnswer((_) async {
          return http.Response('bodyTest', 200);
        });

        final response = await networkService.patch(url, body: body);

        expect(response.statusCode, StatusCode.ok);
        expect(response.body, 'bodyTest');
      });
    });

    group('DELETE -', () {
      test('should call correctly', () async {
        final networkService = locator<NetworkService>();

        when(
          client.delete(
            uri,
            headers: NetworkService.headers,
            encoding: NetworkService.encoding,
          ),
        ).thenAnswer((_) async {
          return http.Response('bodyTest', 200);
        });

        final response = await networkService.delete(url);

        expect(response.statusCode, StatusCode.ok);
        expect(response.body, 'bodyTest');
      });
    });
  });
}
