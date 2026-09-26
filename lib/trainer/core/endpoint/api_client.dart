// lib/core/endpoint/api_client.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../local_storage/user_info.dart';

class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;

  ApiClient({required this.baseUrl, http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final Map<String, String> _defaultHeaders = {
    "Accept": "application/json",
    "Content-Type": "application/json",
  };

  // ─── URL Builder (fixes double slash) ─────────────────────────────
  String _buildUrl(String endpoint) {
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return '$base$path';
  }

  // ─── Auth Header ───────────────────────────────────────────────────
  Future<Map<String, String>> _authHeaders() async {
    final token = await UserInfo.getAccessToken();
    return {
      ..._defaultHeaders,
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  // ─── GET ───────────────────────────────────────────────────────────
  Future<dynamic> get(
      String endpoint, {
        Map<String, String>? headers,
        bool requiresAuth = true,
      }) async {
    final url = Uri.parse(_buildUrl(endpoint));
    final baseHeaders = requiresAuth ? await _authHeaders() : {..._defaultHeaders};
    final mergedHeaders = {...baseHeaders, ...?headers};
    _logRequest("GET", url, mergedHeaders, null);
    final response = await _httpClient.get(url, headers: mergedHeaders);
    return _handleResponse(response, url, method: "GET");
  }

  // ─── POST ──────────────────────────────────────────────────────────
  Future<dynamic> post(
      String endpoint, {
        Map<String, String>? headers,
        dynamic body,
        bool requiresAuth = true,
      }) async {
    final url = Uri.parse(_buildUrl(endpoint));
    final baseHeaders = requiresAuth ? await _authHeaders() : {..._defaultHeaders};
    final mergedHeaders = {...baseHeaders, ...?headers};
    final encodedBody = body != null ? jsonEncode(body) : null;
    _logRequest("POST", url, mergedHeaders, body);
    final response = await _httpClient.post(url, headers: mergedHeaders, body: encodedBody);
    return _handleResponse(response, url, method: "POST");
  }

  // ─── PUT ───────────────────────────────────────────────────────────
  Future<dynamic> put(
      String endpoint, {
        Map<String, String>? headers,
        dynamic body,
        bool requiresAuth = true,
      }) async {
    final url = Uri.parse(_buildUrl(endpoint));
    final baseHeaders = requiresAuth ? await _authHeaders() : {..._defaultHeaders};
    final mergedHeaders = {...baseHeaders, ...?headers};
    final encodedBody = body != null ? jsonEncode(body) : null;
    _logRequest("PUT", url, mergedHeaders, body);
    final response = await _httpClient.put(url, headers: mergedHeaders, body: encodedBody);
    return _handleResponse(response, url, method: "PUT");
  }

  // ─── PATCH ─────────────────────────────────────────────────────────
  Future<dynamic> patch(
      String endpoint, {
        Map<String, String>? headers,
        dynamic body,
        bool requiresAuth = true,
      }) async {
    final url = Uri.parse(_buildUrl(endpoint));
    final baseHeaders = requiresAuth ? await _authHeaders() : {..._defaultHeaders};
    final mergedHeaders = {...baseHeaders, ...?headers};
    final encodedBody = body != null ? jsonEncode(body) : null;
    _logRequest("PATCH", url, mergedHeaders, body);
    final response = await _httpClient.patch(url, headers: mergedHeaders, body: encodedBody);
    return _handleResponse(response, url, method: "PATCH");
  }

  // ─── DELETE ────────────────────────────────────────────────────────
  Future<dynamic> delete(
      String endpoint, {
        Map<String, String>? headers,
        dynamic body,
        bool requiresAuth = true,
      }) async {
    final url = Uri.parse(_buildUrl(endpoint));
    final baseHeaders = requiresAuth ? await _authHeaders() : {..._defaultHeaders};
    final mergedHeaders = {...baseHeaders, ...?headers};
    final encodedBody = body != null ? jsonEncode(body) : null;
    _logRequest("DELETE", url, mergedHeaders, body);
    final response = await _httpClient.delete(url, headers: mergedHeaders, body: encodedBody);
    return _handleResponse(response, url, method: "DELETE");
  }

  // ─── MULTIPART ─────────────────────────────────────────────────────
  Future<dynamic> multipart(
      String endpoint, {
        required String method,
        Map<String, String>? fields,
        Map<String, File>? files,
        bool requiresAuth = true,
      }) async {
    final url = Uri.parse(_buildUrl(endpoint));
    final token = requiresAuth ? await UserInfo.getAccessToken() : null;
    final request = http.MultipartRequest(method, url);
    if (token != null && token.isNotEmpty) {
      request.headers["Authorization"] = "Bearer $token";
    }
    request.headers["Accept"] = "application/json";
    if (fields != null) request.fields.addAll(fields);
    if (files != null) {
      for (final entry in files.entries) {
        final mediaType = _resolveMediaType(entry.value);
        final filename = _resolveFilename(entry.value, mediaType);
        request.files.add(
          await http.MultipartFile.fromPath(
            entry.key,
            entry.value.path,
            filename: filename,
            contentType: mediaType,
          ),
        );
      }
    }
    print("🌐 [$method MULTIPART] URL: $url");
    print("📋 Fields: $fields");
    print("📎 Files: ${files?.keys.toList()}");
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response, url, method: "$method MULTIPART");
  }

  MediaType _resolveMediaType(File file) {
    final path = file.path.toLowerCase();
    if (path.endsWith('.png')) {
      return MediaType('image', 'png');
    } else if (path.endsWith('.webp')) {
      return MediaType('image', 'webp');
    } else if (path.endsWith('.gif')) {
      return MediaType('image', 'gif');
    } else if (path.endsWith('.svg')) {
      return MediaType('image', 'svg+xml');
    } else if (path.endsWith('.avif')) {
      return MediaType('image', 'avif');
    } else if (path.endsWith('.jpg') || path.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    }

    try {
      final bytes = file.openSync().readSync(12);
      if (bytes.length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
        return MediaType('image', 'jpeg');
      }
      if (bytes.length >= 8 &&
          bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47 &&
          bytes[4] == 0x0D && bytes[5] == 0x0A && bytes[6] == 0x1A && bytes[7] == 0x0A) {
        return MediaType('image', 'png');
      }
      if (bytes.length >= 12 &&
          bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46 &&
          bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50) {
        return MediaType('image', 'webp');
      }
      if (bytes.length >= 6 &&
          bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46 &&
          bytes[3] == 0x38 && (bytes[4] == 0x37 || bytes[4] == 0x39) && bytes[5] == 0x61) {
        return MediaType('image', 'gif');
      }
    } catch (_) {}

    return MediaType('image', 'jpeg');
  }

  String _resolveFilename(File file, MediaType mediaType) {
    String filename = file.path.split('/').last.split(r'\').last;
    final lower = filename.toLowerCase();

    // Map .jpg to .jpeg to satisfy backends that strictly check extensions
    if (lower.endsWith('.jpg')) {
      return filename.replaceAll(RegExp(r'\.jpg$', caseSensitive: false), '.jpeg');
    }

    if (lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.avif') ||
        lower.endsWith('.svg')) {
      return filename;
    }

    switch ('${mediaType.type}/${mediaType.subtype}') {
      case 'image/png':
        return '$filename.png';
      case 'image/webp':
        return '$filename.webp';
      case 'image/gif':
        return '$filename.gif';
      case 'image/svg+xml':
        return '$filename.svg';
      case 'image/avif':
        return '$filename.avif';
      case 'image/jpeg':
      default:
        return '$filename.jpeg';
    }
  }

  // ─── Response Handler ──────────────────────────────────────────────
  dynamic _handleResponse(http.Response response, Uri url, {required String method}) {
    print("📩 [$method] Status: ${response.statusCode}");
    print("📩 [$method] Body: ${response.body}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw HttpException(
          message: "Invalid JSON format",
          statusCode: response.statusCode,
          uri: url,
          body: response.body,
        );
      }
    }

    String errorMessage = "Request failed";
    try {
      final errorBody = jsonDecode(response.body);
      if (errorBody is Map<String, dynamic>) {
        if (errorBody.containsKey('detail')) {
          errorMessage = errorBody['detail'].toString();
        } else {
          errorMessage = errorBody.entries.map((e) {
            final val = e.value;
            if (val is List) return "${e.key}: ${val.join(', ')}";
            return "${e.key}: $val";
          }).join(" | ");
        }
      }
    } catch (_) {
      errorMessage = response.body.isNotEmpty ? response.body : "Request failed";
    }

    switch (response.statusCode) {
      case 400:
        throw HttpException(message: errorMessage, statusCode: 400, uri: url, body: response.body);
      case 401:
        throw UnauthorizedException(uri: url, body: response.body);
      case 403:
        throw ForbiddenException(uri: url, body: response.body);
      case 404:
        throw NotFoundException(uri: url, body: response.body);
      case 500:
      case 502:
      case 503:
        throw ServerException(uri: url, body: response.body);
      default:
        throw HttpException(message: errorMessage, statusCode: response.statusCode, uri: url, body: response.body);
    }
  }

  // ─── Logger ────────────────────────────────────────────────────────
  void _logRequest(String method, Uri url, Map<String, String> headers, dynamic body) {
    print("─────────────────────────────────────");
    print("🌐 [$method] $url");
    print("📋 Headers: $headers");
    if (body != null) print("📦 Body: $body");
    print("─────────────────────────────────────");
  }
}

// ─── Exceptions ────────────────────────────────────────────────────
class HttpException implements Exception {
  final String message;
  final int statusCode;
  final Uri uri;
  final String? body;

  const HttpException({
    required this.message,
    required this.statusCode,
    required this.uri,
    this.body,
  });

  @override
  String toString() => "HttpException [$statusCode]: $message | URL: $uri";
}

class UnauthorizedException extends HttpException {
  UnauthorizedException({required Uri uri, String? body})
      : super(message: "Unauthorized. Please log in again.", statusCode: 401, uri: uri, body: body);
}

class ForbiddenException extends HttpException {
  ForbiddenException({required Uri uri, String? body})
      : super(message: "Access denied.", statusCode: 403, uri: uri, body: body);
}

class NotFoundException extends HttpException {
  NotFoundException({required Uri uri, String? body})
      : super(message: "Resource not found.", statusCode: 404, uri: uri, body: body);
}

class ServerException extends HttpException {
  ServerException({required Uri uri, String? body})
      : super(message: "Server error. Please try again later.", statusCode: 500, uri: uri, body: body);
}