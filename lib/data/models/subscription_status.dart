class SubscriptionStatus {
  const SubscriptionStatus({
    required this.isPremium,
    required this.planName,
    this.activeSubscription,
    this.pendingPayment,
  });

  final bool isPremium;
  final String planName;
  final SubscriptionRecord? activeSubscription;
  final SubscriptionPayment? pendingPayment;

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      isPremium: _parseBool(json['is_premium']),
      planName: (json['plan_name'] ?? 'free').toString(),
      activeSubscription: SubscriptionRecord.tryParse(
        json['active_subscription'] ?? json['subscription'],
      ),
      pendingPayment: SubscriptionPayment.tryParse(json['pending_payment']),
    );
  }

  bool get hasPendingPayment => pendingPayment != null;

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    final text = value?.toString().toLowerCase();
    return text == '1' || text == 'true';
  }
}

class SubscriptionRecord {
  const SubscriptionRecord({
    this.id,
    this.planName,
    this.status,
    this.startedAt,
    this.endsAt,
  });

  final int? id;
  final String? planName;
  final String? status;
  final String? startedAt;
  final String? endsAt;

  factory SubscriptionRecord.fromJson(Map<String, dynamic> json) {
    return SubscriptionRecord(
      id: _parseInt(json['id']),
      planName: json['plan_name']?.toString(),
      status: json['status']?.toString(),
      startedAt: json['started_at']?.toString(),
      endsAt: json['ends_at']?.toString(),
    );
  }

  static SubscriptionRecord? tryParse(dynamic value) {
    final map = _asMap(value);
    if (map == null) {
      return null;
    }

    return SubscriptionRecord.fromJson(map);
  }
}

class SubscriptionPayment {
  const SubscriptionPayment({
    required this.orderId,
    required this.paymentStatus,
    this.amount,
    this.snapToken,
    this.redirectUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String orderId;
  final String paymentStatus;
  final String? amount;
  final String? snapToken;
  final String? redirectUrl;
  final String? createdAt;
  final String? updatedAt;

  factory SubscriptionPayment.fromJson(Map<String, dynamic> json) {
    return SubscriptionPayment(
      orderId: (json['order_id'] ?? '').toString(),
      paymentStatus: (json['payment_status'] ?? json['status'] ?? '').toString(),
      amount: json['amount']?.toString(),
      snapToken: json['snap_token']?.toString(),
      redirectUrl: json['redirect_url']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  bool get isPending => paymentStatus.toLowerCase() == 'pending';
  bool get canOpenPayment =>
      (snapToken != null && snapToken!.isNotEmpty) ||
      (redirectUrl != null && redirectUrl!.isNotEmpty);

  static SubscriptionPayment? tryParse(dynamic value) {
    final map = _asMap(value);
    if (map == null) {
      return null;
    }

    return SubscriptionPayment.fromJson(map);
  }
}

int? _parseInt(dynamic value) {
  if (value is int) {
    return value;
  }

  return int.tryParse(value?.toString() ?? '');
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
