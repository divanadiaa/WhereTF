import '../models/subscription_status.dart';
import 'api_client.dart';

class SubscriptionService {
  SubscriptionService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<SubscriptionStatus> getSubscription() async {
    final response = await _apiClient.get(
      '/subscription',
      requiresAuth: true,
    );

    return SubscriptionStatus.fromJson(_extractDataMap(response));
  }

  Future<SubscriptionPayment> upgradeToPremium({
    String? returnUrl,
  }) async {
    final body = <String, dynamic>{};
    if (returnUrl != null && returnUrl.isNotEmpty) {
      body['return_url'] = returnUrl;
      body['finish_url'] = returnUrl;
    }

    final response = await _apiClient.post(
      '/subscription/upgrade',
      body: body,
      requiresAuth: true,
    );
    final data = _extractDataMap(response);
    final payment = SubscriptionPayment.tryParse(data['payment']);

    if (payment == null || !payment.canOpenPayment) {
      throw ApiException('Response pembayaran premium tidak valid.');
    }

    return payment;
  }

  Future<List<SubscriptionPayment>> getPayments() async {
    final response = await _apiClient.get(
      '/subscription/payments',
      requiresAuth: true,
    );
    final rawPayments = _extractList(response['data']) ??
        _extractList(response['payments']) ??
        _extractList(response);

    if (rawPayments == null) {
      return const <SubscriptionPayment>[];
    }

    return rawPayments
        .map(_asMap)
        .whereType<Map<String, dynamic>>()
        .map(SubscriptionPayment.fromJson)
        .toList();
  }

  Future<void> cancelPendingPayment(String orderId) async {
    await _apiClient.post(
      '/subscription/payment/cancel',
      body: {
        'order_id': orderId,
      },
      requiresAuth: true,
    );
  }

  Future<void> cancelSubscription() async {
    await _apiClient.post(
      '/subscription/cancel',
      requiresAuth: true,
    );
  }

  Map<String, dynamic> _extractDataMap(Map<String, dynamic> response) {
    final data = _asMap(response['data']);
    if (data != null) {
      return data;
    }

    return response;
  }

  List<dynamic>? _extractList(dynamic value) {
    if (value is List) {
      return value;
    }

    final map = _asMap(value);
    if (map == null) {
      return null;
    }

    for (final key in const ['payments', 'items', 'data']) {
      final nested = map[key];
      if (nested is List) {
        return nested;
      }

      final nestedList = _extractList(nested);
      if (nestedList != null) {
        return nestedList;
      }
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
