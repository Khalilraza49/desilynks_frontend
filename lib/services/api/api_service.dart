import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_endpoints.dart';
import '../local/storage_service.dart';

class ApiService {
  final String _baseUrl = ApiEndpoints.baseUrl;
  final StorageService _storageService;

  static void Function()? onSessionExpired;
  static DateTime? _lastUnauthorizedTime;

  ApiService(this._storageService);

  // Common headers
  Map<String, String> _getHeaders({bool includeContentTypeJson = true}) {
    final Map<String, String> headers = {
      if (includeContentTypeJson) 'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Inject access token if cached
    final token = _storageService.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      final masked = token.length > 10
          ? '${token.substring(0, 5)}...${token.substring(token.length - 5)}'
          : token;
      developer.log(
        'Auth Header injected: Bearer $masked',
        name: 'api_service',
      );
    } else {
      developer.log(
        'Auth Header: No token found in storage!',
        name: 'api_service',
      );
    }
    return headers;
  }

  MediaType? _getMimeType(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    if (ext == 'jpg' || ext == 'jpeg') {
      return MediaType('image', 'jpeg');
    } else if (ext == 'png') {
      return MediaType('image', 'png');
    } else if (ext == 'webp') {
      return MediaType('image', 'webp');
    } else if (ext == 'heic') {
      return MediaType('image', 'jpeg');
    } else if (ext == 'mp4') {
      return MediaType('video', 'mp4');
    }
    return null;
  }

  Future<bool>? _refreshFuture;

  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/verify-otp') ||
        path.contains('/auth/resend-otp') ||
        path.contains('/auth/forgot-password') ||
        path.contains('/auth/reset-password') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/logout');
  }

  Future<bool> _refreshTokenInternal() async {
    final refreshToken = _storageService.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      developer.log(
        'Token refresh skipped: No refreshToken stored.',
        name: 'api_service',
      );
      return false;
    }

    try {
      final uri = Uri.parse('$_baseUrl${ApiEndpoints.refreshEndpoint}');
      developer.log(
        'Attempting silent token refresh at: $uri',
        name: 'api_service',
      );
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      developer.log(
        'Token refresh response status: ${response.statusCode}',
        name: 'api_service',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await _storageService.saveToken(newAccessToken);
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await _storageService.saveRefreshToken(newRefreshToken);
          }
          final user = _storageService.getUser();
          if (user != null) {
            await _storageService.saveUser(user.copyWith(token: newAccessToken));
          }
          developer.log(
            'Silent token refresh succeeded. New tokens saved.',
            name: 'api_service',
          );
          return true;
        }
      }
      developer.log(
        'Silent token refresh failed with status ${response.statusCode}: ${response.body}',
        name: 'api_service',
      );
      return false;
    } catch (e, stack) {
      developer.log(
        'Token refresh exception: $e',
        name: 'api_service',
        error: e,
        stackTrace: stack,
      );
      return false;
    }
  }

  Future<bool> _synchronizedRefresh() async {
    if (_refreshFuture != null) {
      return await _refreshFuture!;
    }
    _refreshFuture = _refreshTokenInternal();
    try {
      return await _refreshFuture!;
    } finally {
      _refreshFuture = null;
    }
  }

  // ── Generic request handler ───────────────────────────────────────────────
  // All public HTTP methods delegate here. Logs, headers, encoding, error
  // handling and response processing are centralized in one place.
  Future<http.Response> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool isRetry = false,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final encodedBody = body != null ? jsonEncode(body) : null;
    final logPayload =
        encodedBody != null ? '\nPayload: $encodedBody' : '';

    developer.log(
      'API Request [$method] to: $_baseUrl$endpoint$logPayload (retry: $isRetry)',
      name: 'api_service',
    );
    try {
      final http.Response response;
      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: _getHeaders());
        case 'POST':
          response = await http.post(uri, headers: _getHeaders(), body: encodedBody);
        case 'PUT':
          response = await http.put(uri, headers: _getHeaders(), body: encodedBody);
        case 'PATCH':
          response = await http.patch(uri, headers: _getHeaders(), body: encodedBody);
        case 'DELETE':
          response = await http.delete(uri, headers: _getHeaders(), body: encodedBody);
        default:
          throw UnsupportedError('HTTP method $method is not supported');
      }
      developer.log(
        'API Response [$method] [$endpoint] Status: ${response.statusCode}',
        name: 'api_service',
      );

      // Check 401 unauthorized and attempt silent token refresh + retry
      final isDeleteAccount = method == 'DELETE' &&
          (endpoint == ApiEndpoints.userProfileEndpoint ||
              endpoint == ApiEndpoints.deleteAccountEndpoint);
      if (response.statusCode == 401 &&
          !isRetry &&
          !_isAuthEndpoint(endpoint) &&
          !isDeleteAccount) {
        final hadToken = _storageService.getToken()?.isNotEmpty ?? false;
        if (hadToken) {
          final refreshed = await _synchronizedRefresh();
          if (refreshed) {
            developer.log(
              'Retrying [$method] $endpoint with refreshed token...',
              name: 'api_service',
            );
            return await _request(
              method,
              endpoint,
              body: body,
              isRetry: true,
            );
          }
        }
      }

      return _handleResponse(response);
    } catch (e) {
      developer.log(
        'API Exception [$method] [$endpoint]: $e',
        name: 'api_service',
        error: e,
      );
      rethrow;
    }
  }

  // GET Request
  Future<http.Response> get(String endpoint) =>
      _request('GET', endpoint);

  // POST Request (kept as a real method so subclasses like MockApiService can override)
  Future<http.Response> post(String endpoint, [Map<String, dynamic>? body]) =>
      _request('POST', endpoint, body: body);

  // PUT Request
  Future<http.Response> put(String endpoint, Map<String, dynamic> body) =>
      _request('PUT', endpoint, body: body);

  // PATCH Request
  Future<http.Response> patch(String endpoint, Map<String, dynamic> body) =>
      _request('PATCH', endpoint, body: body);

  // DELETE Request
  Future<http.Response> delete(String endpoint, {Map<String, dynamic>? body}) =>
      _request('DELETE', endpoint, body: body);

  // Generalized Multipart Request (supports POST/PATCH, single and list of files)
  Future<http.Response> multipartRequest({
    required String method,
    required String endpoint,
    required Map<String, String> fields,
    List<File>? files,
    String filesKey = 'photos',
    File? singleFile,
    String singleFileKey = 'profilePhoto',
    Map<String, List<File>>? filesMap,
    bool isRetry = false,
  }) async {
    developer.log(
      'API Request [$method MULTIPART] to: $_baseUrl$endpoint\nFields: $fields\nFiles: ${files?.map((f) => f.path).toList()}\nSingle File: ${singleFile?.path}\nFilesMap: ${filesMap?.map((k, v) => MapEntry(k, v.map((f) => f.path).toList()))}',
      name: 'api_service',
    );
    try {
      final request = http.MultipartRequest(
        method,
        Uri.parse('$_baseUrl$endpoint'),
      );

      // Add text fields
      request.fields.addAll(fields);

      // Attach list of files if present
      if (files != null && files.isNotEmpty) {
        for (final file in files) {
          final multipartFile = await http.MultipartFile.fromPath(
            filesKey,
            file.path,
            contentType: _getMimeType(file.path),
          );
          request.files.add(multipartFile);
        }
      }

      // Attach single file if present
      if (singleFile != null) {
        final multipartFile = await http.MultipartFile.fromPath(
          singleFileKey,
          singleFile.path,
          contentType: _getMimeType(singleFile.path),
        );
        request.files.add(multipartFile);
      }

      // Attach map of file lists if present
      if (filesMap != null && filesMap.isNotEmpty) {
        for (final entry in filesMap.entries) {
          final fieldKey = entry.key;
          for (final file in entry.value) {
            final multipartFile = await http.MultipartFile.fromPath(
              fieldKey,
              file.path,
              contentType: _getMimeType(file.path),
            );
            request.files.add(multipartFile);
          }
        }
      }

      int totalFileBytes = 0;
      if (files != null) {
        for (final f in files) {
          totalFileBytes += await f.length();
        }
      }
      if (singleFile != null) {
        totalFileBytes += await singleFile.length();
      }
      if (filesMap != null) {
        for (final list in filesMap.values) {
          for (final f in list) {
            totalFileBytes += await f.length();
          }
        }
      }
      final double totalMb = totalFileBytes / (1024 * 1024);
      developer.log(
        'API Request [$method MULTIPART] Total File Size: ${totalMb.toStringAsFixed(2)} MB',
        name: 'api_service',
      );

      // Attach authorization headers (if any) without setting application/json Content-Type
      request.headers.addAll(_getHeaders(includeContentTypeJson: false));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      developer.log(
        'API Response [$method MULTIPART] [$endpoint] Status: ${response.statusCode}',
        name: 'api_service',
      );

      // Check 401 unauthorized and attempt silent token refresh + retry
      if (response.statusCode == 401 && !isRetry && !_isAuthEndpoint(endpoint)) {
        final hadToken = _storageService.getToken()?.isNotEmpty ?? false;
        if (hadToken) {
          final refreshed = await _synchronizedRefresh();
          if (refreshed) {
            developer.log(
              'Retrying [$method MULTIPART] $endpoint with refreshed token...',
              name: 'api_service',
            );
            return await multipartRequest(
              method: method,
              endpoint: endpoint,
              fields: fields,
              files: files,
              filesKey: filesKey,
              singleFile: singleFile,
              singleFileKey: singleFileKey,
              filesMap: filesMap,
              isRetry: true,
            );
          }
        }
      }

      return _handleResponse(response, totalSizeMb: totalMb);
    } catch (e) {
      developer.log(
        'API Exception [$method MULTIPART] [$endpoint]: $e',
        name: 'api_service',
        error: e,
      );
      rethrow;
    }
  }

  // Handle Response and convert errors into meaningful Exception messages
  http.Response _handleResponse(http.Response response, {double? totalSizeMb}) {
    developer.log('Response Body: ${response.body}', name: 'api_service');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else if (response.statusCode == 401) {
      String errorMessage = 'Session expired. Please log in again.';
      try {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final message = data['message'];
        if (message is List) {
          errorMessage = message.join('\n');
        } else if (message is String && message.isNotEmpty) {
          errorMessage = message;
        }
      } catch (_) {}

      final path = response.request?.url.path ?? '';
      final isDeleteUser = response.request?.method == 'DELETE' &&
          (path.endsWith('/user') ||
              path == ApiEndpoints.userProfileEndpoint ||
              path == ApiEndpoints.deleteAccountEndpoint);
      final isPasswordError =
          errorMessage.toLowerCase().contains('password');

      if (_isAuthEndpoint(path) || isDeleteUser || isPasswordError) {
        developer.log(
          'API Error Response [401] on auth/password endpoint: $errorMessage',
          name: 'api_service',
        );
        throw HttpException(errorMessage);
      }

      final hadToken = _storageService.getToken()?.isNotEmpty ?? false;
      if (hadToken) {
        _storageService.clearSession();
        developer.log(
          'API Error Response [401]: Session expired. Token cleared.',
          name: 'api_service',
        );
        final now = DateTime.now();
        if (_lastUnauthorizedTime == null ||
            now.difference(_lastUnauthorizedTime!) > const Duration(seconds: 4)) {
          _lastUnauthorizedTime = now;
          onSessionExpired?.call();
        }
      } else {
        developer.log(
          'API Error Response [401]: Guest mode - session expiry redirect suppressed.',
          name: 'api_service',
        );
      }
      throw HttpException(errorMessage);
    } else if (response.statusCode == 413) {
      final sizeInfo = totalSizeMb != null && totalSizeMb > 0
          ? ' (Total size: ${totalSizeMb.toStringAsFixed(2)} MB)'
          : '';
      final msg =
          'Selected image size is too large$sizeInfo. Please compress your photos before uploading.';
      developer.log('API Error Response [413]: $msg', name: 'api_service');
      throw HttpException(msg);
    } else if (response.statusCode == 429) {
      final retryAfter = response.headers['retry-after'] ??
          response.headers['retry-after-account'];
      String msg = 'Too many requests. Please try again later.';
      try {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['message'] is String && (data['message'] as String).isNotEmpty) {
          msg = data['message'];
        }
      } catch (_) {}
      if (retryAfter != null && retryAfter.isNotEmpty) {
        msg = 'Too many requests. Please try again in $retryAfter seconds.';
      }
      developer.log('API Error Response [429]: $msg', name: 'api_service');
      throw HttpException(msg);
    } else {
      String errorMessage = 'Something went wrong';
      try {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final message = data['message'];
        if (message is List) {
          errorMessage = message.join('\n');
        } else if (message is String) {
          errorMessage = message;
        }
      } catch (_) {
        if (response.statusCode == 413 ||
            response.body.contains('413 Request Entity Too Large')) {
          final sizeInfo = totalSizeMb != null && totalSizeMb > 0
              ? ' (Total size: ${totalSizeMb.toStringAsFixed(2)} MB)'
              : '';
          errorMessage =
              'Selected image size is too large$sizeInfo. Please compress your photos before uploading.';
        }
      }

      if (response.statusCode == 400 &&
          (errorMessage.toLowerCase().contains('invalid or corrupted image') ||
              errorMessage.toLowerCase().contains('corrupted image'))) {
        errorMessage = "This image couldn't be processed, please try another.";
      }

      developer.log(
        'API Error Response [${response.statusCode}]: $errorMessage',
        name: 'api_service',
      );
      throw HttpException(errorMessage);
    }
  }
}
