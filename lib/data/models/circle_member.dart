import 'app_user.dart';

class CircleMember {
  const CircleMember({
    required this.id,
    required this.circleId,
    required this.userId,
    required this.role,
    required this.status,
    this.joinedAt,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  final int id;
  final int circleId;
  final int userId;
  final String role;
  final String status;
  final String? joinedAt;
  final String? createdAt;
  final String? updatedAt;
  final AppUser? user;

  CircleMember copyWith({
    AppUser? user,
  }) {
    return CircleMember(
      id: id,
      circleId: circleId,
      userId: userId,
      role: role,
      status: status,
      joinedAt: joinedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      user: user ?? this.user,
    );
  }

  factory CircleMember.fromJson(Map<String, dynamic> json) {
    final rawUser = _asMap(json['user']);
    final parsedUser = rawUser == null ? null : AppUser.fromJson(rawUser);

    return CircleMember(
      id: _parseInt(json['id']),
      circleId: _parseInt(json['circle_id']),
      userId: _parseInt(json['user_id'] ?? rawUser?['id']),
      role: (json['role'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      joinedAt: json['joined_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      user: parsedUser,
    );
  }

  String get displayName {
    final name = user?.name.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }

    return 'User $userId';
  }

  String? get contactLabel {
    final email = user?.email.trim();
    if (email != null && email.isNotEmpty) {
      return email;
    }

    final phone = user?.phone?.trim();
    if (phone != null && phone.isNotEmpty) {
      return phone;
    }

    return null;
  }

  String get initials {
    final userInitials = user?.initials;
    if (userInitials != null && userInitials.isNotEmpty) {
      return userInitials;
    }

    final parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  bool get hasOwnerRole {
    final normalized = role.toLowerCase();
    return normalized == 'owner' ||
        normalized == 'ketua' ||
        normalized == 'admin';
  }

  String get displayRole => _displayLabel(role, fallback: 'Member');

  String get displayStatus => _displayLabel(status, fallback: 'Unknown');

  static String _displayLabel(String value, {required String fallback}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return fallback;
    }

    return trimmed[0].toUpperCase() + trimmed.substring(1).toLowerCase();
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
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
