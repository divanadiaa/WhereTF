import '../../core/config/app_config.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photo,
    this.photoUrl,
  });

  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? photo;
  final String? photoUrl;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: _parseId(json['id']),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: json['phone']?.toString(),
      photo: json['photo']?.toString(),
      photoUrl: (json['photo_url'] ?? json['photoUrl'] ?? json['avatar_url'])
          ?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photo': photo,
      'photo_url': photoUrl,
    };
  }

  String? get displayPhotoUrl {
    final directUrl = _clean(photoUrl);
    if (directUrl != null) {
      return _resolvePhotoUrl(directUrl);
    }

    final path = _clean(photo);
    if (path == null) {
      return null;
    }

    return _resolvePhotoUrl(path);
  }

  String get initials {
    final parts = name
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

  static int _parseId(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  static String _resolvePhotoUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) {
      final path = uri.path.replaceFirst(RegExp(r'^/+'), '');
      if (_isLocalHost(uri.host) || path.startsWith('api/storage/')) {
        return _resolveStoragePath(path);
      }

      return value;
    }

    return _resolveStoragePath(value);
  }

  static String _resolveStoragePath(String value) {
    final baseUrl = _storageBaseUrl;
    final withoutLeadingSlash = value.replaceFirst(RegExp(r'^/+'), '');
    final normalizedPath = withoutLeadingSlash.replaceFirst(
      RegExp(r'^api/+'),
      '',
    );

    if (normalizedPath.startsWith('storage/')) {
      return '$baseUrl/$normalizedPath';
    }

    return '$baseUrl/storage/$normalizedPath';
  }

  static String get _storageBaseUrl {
    return AppConfig.baseUrl
        .replaceFirst(RegExp(r'/api/?$'), '')
        .replaceFirst(RegExp(r'/+$'), '');
  }

  static bool _isLocalHost(String host) {
    return host == 'localhost' ||
        host == '127.0.0.1' ||
        host == '0.0.0.0' ||
        host == '::1';
  }
}
