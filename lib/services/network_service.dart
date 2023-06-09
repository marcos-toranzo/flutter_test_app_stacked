import 'package:collection/collection.dart';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

Client httpClient = Client();

typedef HttpMethod = Future<Response> Function(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
});

class NetworkService {
  static const baseUrl = 'https://dummyjson.com';

  static final encoding = Encoding.getByName('utf-8');

  static const headers = {
    HttpHeaders.acceptHeader: 'application/json',
    HttpHeaders.contentTypeHeader: 'application/json',
  };

  Future<NetworkResponse> _request(
    HttpMethod method,
    String endpoint, {
    Map<String, dynamic> params = const {},
    Map<String, dynamic>? body,
  }) async {
    final url = '$baseUrl/$endpoint';

    var urlWithParams = '$url?${Uri(queryParameters: params).query}';

    final response = await method(
      Uri.parse(urlWithParams),
      headers: headers,
      body: body != null ? json.encode(body) : null,
      encoding: encoding,
    ).timeout(
      const Duration(seconds: 5),
      onTimeout: () => Response('timeout', StatusCode.timeout.code),
    );

    return NetworkResponse(
      statusCode: StatusCode.fromCode(response.statusCode),
      body: response.body,
    );
  }

  Future<NetworkResponse> get(
    String endpoint, {
    Map<String, dynamic> params = const {},
  }) =>
      _request(
        (endpoint, {body, encoding, headers}) =>
            httpClient.get(endpoint, headers: headers),
        endpoint,
        params: params,
      );

  Future<NetworkResponse> post(
    String endpoint, {
    Map<String, dynamic> body = const <String, dynamic>{},
  }) =>
      _request(httpClient.post, endpoint, body: body);

  Future<NetworkResponse> put(
    String endpoint, {
    Map<String, dynamic> body = const <String, dynamic>{},
  }) =>
      _request(httpClient.put, endpoint, body: body);

  Future<NetworkResponse> patch(
    String endpoint, {
    Map<String, dynamic> body = const <String, dynamic>{},
  }) =>
      _request(httpClient.patch, endpoint, body: body);

  Future<NetworkResponse> delete(String endpoint) =>
      _request(httpClient.delete, endpoint);
}

class ApiResponse<T> {
  final T? data;
  final bool success;
  final String? errorMessage;
  final int? total;
  final int? skip;
  final int? limit;

  const ApiResponse({
    required this.success,
    this.data,
    this.errorMessage,
    this.total,
    this.skip,
    this.limit,
  });
}

class SuccessApiResponse<T> extends ApiResponse<T> {
  const SuccessApiResponse({
    super.data,
    super.total,
    super.skip,
    super.limit,
  }) : super(success: true);
}

class ErrorApiResponse<T> extends ApiResponse<T> {
  const ErrorApiResponse({
    super.errorMessage,
  }) : super(success: false);
}

class NetworkResponse {
  final StatusCode statusCode;
  final String body;

  const NetworkResponse({
    required this.statusCode,
    required this.body,
  });
}

enum StatusCode {
  ok(200),
  created(201),
  badRequest(400),
  notFound(404),
  timeout(408),
  unauthorized(401),
  unknown(0);

  final int code;
  const StatusCode(this.code);

  factory StatusCode.fromCode(int statusCode) {
    final knownErrorCode = values.firstWhereOrNull(
      (value) => value.code == statusCode,
    );

    return knownErrorCode ?? StatusCode.unknown;
  }
}
