import '../models/circle_summary.dart';
import 'api_client.dart';

class CircleActionResult {
  const CircleActionResult({
    required this.message,
    required this.circle,
  });

  final String message;
  final CircleSummary circle;
}

class CircleService {
  CircleService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<CircleActionResult> joinCircle(String referalCode) async {
    final response = await _apiClient.post(
      '/circles/join',
      body: {
        'referal_code': referalCode,
      },
      requiresAuth: true,
    );

    return _parseResult(response);
  }

  Future<CircleActionResult> leaveCircle() async {
    final response = await _apiClient.post(
      '/circles/leave',
      body: <String, dynamic>{},
      requiresAuth: true,
    );

    return _parseResult(response);
  }

  CircleActionResult _parseResult(Map<String, dynamic> response) {
    final rawData = _extractCircleMap(response['data']) ??
        _extractCircleMap(response['circle']) ??
        _extractCircleMap(response);

    if (rawData == null) {
      throw ApiException('Response circle tidak valid.');
    }

    return CircleActionResult(
      message: (response['message'] ?? 'Circle updated').toString(),
      circle: CircleSummary.fromJson(rawData),
    );
  }

  Map<String, dynamic>? _extractCircleMap(dynamic value) {
    final map = _asMap(value);
    if (map == null) {
      return null;
    }

    final nestedCircle = _asMap(map['circle']) ??
        _asMap(map['current_circle']) ??
        _asMap(map['active_circle']);

    if (nestedCircle != null) {
      return nestedCircle;
    }

    if (map.containsKey('id')) {
      return map;
    }

    return null;
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(key.toString(), item),
      );
    }

    return null;
  }
}
