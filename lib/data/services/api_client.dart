import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/config/app_config.dart';
import 'auth_storage.dart';

class ApiClient {
  ApiClient({AuthStorage? authStorage})
      : _authStorage = authStorage ?? AuthStorage();

  final AuthStorage _authStorage;

  Future<Map<String, dynamic>> get(
    String endpoint, {
    bool requiresAuth = false,
  }) async {
    return _send(
      method: 'GET',
      endpoint: endpoint,
      requiresAuth: requiresAuth,
    );
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    return _send(
      method: 'POST',
      endpoint: endpoint,
      body: body,
      requiresAuth: requiresAuth,
    );
  }

  Future<Map<String, dynamic>> postMultipartFile(
    String endpoint, {
    required String fieldName,
    required XFile file,
    bool requiresAuth = false,
  }) async {
    try {
      final headers = await _buildMultipartHeaders(requiresAuth: requiresAuth);
      final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');

      _logRequest('POST', uri, headers);

      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(headers);

      final filename = _fileName(file);
      final contentType = _imageContentType(filename);
      final multipartFile = kIsWeb
          ? http.MultipartFile.fromBytes(
              fieldName,
              await file.readAsBytes(),
              filename: filename,
              contentType: contentType,
            )
          : await http.MultipartFile.fromPath(
              fieldName,
              file.path,
              filename: filename,
              contentType: contentType,
            );

      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      _logResponse('POST', uri, response);

      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw ApiException('Request browser gagal: ${e.message}');
    } on SocketException {
      throw ApiException('Tidak bisa terhubung ke server.');
    }
  }

  Future<Map<String, dynamic>> _send({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    required bool requiresAuth,
  }) async {
    try {
      final headers = await _buildHeaders(requiresAuth: requiresAuth);
      final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');

      _logRequest(method, uri, headers);

      late final http.Response response;
      if (method == 'GET') {
        response = await http.get(uri, headers: headers);
      } else {
        response = await http.post(
          uri,
          headers: headers,
          body: jsonEncode(body ?? <String, dynamic>{}),
        );
      }

      _logResponse(method, uri, response);

      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw ApiException('Request browser gagal: ${e.message}');
    } on SocketException {
      throw ApiException('Tidak bisa terhubung ke server.');
    }
  }

  void _logRequest(
    String method,
    Uri uri,
    Map<String, String> headers,
  ) {
    if (!kDebugMode) {
      return;
    }

    debugPrint('[API] $method $uri');
    debugPrint('[API] request headers: ${_sanitizeHeaders(headers)}');
  }

  void _logResponse(
    String method,
    Uri uri,
    http.Response response,
  ) {
    if (!kDebugMode) {
      return;
    }

    debugPrint('[API] $method $uri -> ${response.statusCode}');
    debugPrint(
      '[API] response content-type: ${response.headers['content-type']}',
    );
    debugPrint('[API] raw response body: ${_sanitizeBody(response.body)}');
  }

  Future<Map<String, String>> _buildHeaders({
    required bool requiresAuth,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };

    if (requiresAuth) {
      final token = await _authStorage.readToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<Map<String, String>> _buildMultipartHeaders({
    required bool requiresAuth,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };

    if (requiresAuth) {
      final token = await _authStorage.readToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    return headers.map((key, value) {
      if (key.toLowerCase() == 'authorization') {
        return MapEntry(key, 'Bearer ***');
      }

      return MapEntry(key, value);
    });
  }

  String _sanitizeBody(String body) {
    return body
        .replaceAll(
          RegExp(r'"token"\s*:\s*"[^"]+"'),
          '"token":"***"',
        )
        .replaceAll(
          RegExp(r'"snap_token"\s*:\s*"[^"]+"'),
          '"snap_token":"***"',
        );
  }

  Map<String, dynamic>? _tryDecodeResponse(String body) {
    if (body.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return <String, dynamic>{'data': decoded};
    } on FormatException {
      return null;
    }
  }

  Future<Map<String, dynamic>> _handleResponse(
    http.Response response,
  ) async {
    final decoded = _tryDecodeResponse(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded == null) {
        throw ApiException(
          'Response server tidak valid.',
          statusCode: response.statusCode,
        );
      }

      return decoded;
    }

    if (response.statusCode == 401) {
      await _authStorage.clearSession();
      throw UnauthorizedException();
    }

    if (response.statusCode == 422) {
      throw ApiValidationException(
        message: decoded == null
            ? 'Validation error'
            : _extractValidationMessage(decoded),
        errors: decoded == null
            ? <String, List<String>>{}
            : _extractErrors(decoded),
      );
    }

    throw ApiException(
      decoded == null
          ? _fallbackHttpMessage(response.statusCode)
          : _extractMessage(
              decoded,
              fallback: _fallbackHttpMessage(response.statusCode),
            ),
      statusCode: response.statusCode,
    );
  }

  String _fileName(XFile file) {
    final name = file.name.trim();
    if (name.isNotEmpty) {
      return name;
    }

    final segments = file.path.split(RegExp(r'[\\/]'));
    if (segments.isNotEmpty && segments.last.isNotEmpty) {
      return segments.last;
    }

    return 'photo.jpg';
  }

  MediaType? _imageContentType(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    if (extension == 'jpg' || extension == 'jpeg') {
      return MediaType('image', 'jpeg');
    }

    if (extension == 'png') {
      return MediaType('image', 'png');
    }

    return null;
  }

  String _fallbackHttpMessage(int statusCode) {
    if (statusCode == 404) {
      return 'Endpoint API tidak ditemukan.';
    }

    if (statusCode == 429) {
      return 'Terlalu banyak request. Coba lagi sebentar lagi.';
    }

    if (statusCode == 504) {
      return 'Server tidak merespons tepat waktu. Cek backend atau tunnel ngrok.';
    }

    if (statusCode >= 500) {
      return 'Server sedang bermasalah. Coba lagi nanti.';
    }

    return 'Request gagal.';
  }

  String _extractMessage(
    Map<String, dynamic> json, {
    required String fallback,
  }) {
    return (json['message'] ?? fallback).toString();
  }

  String _extractValidationMessage(Map<String, dynamic> json) {
    final errors = _extractErrors(json);
    if (errors.isEmpty) {
      return _extractMessage(json, fallback: 'Validation error');
    }

    return errors.values.expand((items) => items).join('\n');
  }

  Map<String, List<String>> _extractErrors(Map<String, dynamic> json) {
    final rawErrors = json['errors'];
    if (rawErrors is! Map) {
      return <String, List<String>>{};
    }

    return rawErrors.map((key, value) {
      if (value is List) {
        return MapEntry(
          key.toString(),
          value.map((item) => item.toString()).toList(),
        );
      }

      return MapEntry(key.toString(), <String>[value.toString()]);
    });
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errors;

  ApiException(
    this.message, {
    this.statusCode,
    this.errors,
  });

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException() : super('Unauthenticated', statusCode: 401);
}

class ApiValidationException extends ApiException {
  ApiValidationException({
    required String message,
    required Map<String, List<String>> errors,
  }) : super(
          message,
          statusCode: 422,
          errors: errors,
        );
}
