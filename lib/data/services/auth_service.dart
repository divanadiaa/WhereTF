import 'package:image_picker/image_picker.dart';

import '../models/app_user.dart';
import 'api_client.dart';
import 'auth_storage.dart';

class AuthService {
  AuthService({
    ApiClient? apiClient,
    AuthStorage? authStorage,
  })  : _authStorage = authStorage ?? AuthStorage(),
        _apiClient =
            apiClient ?? ApiClient(authStorage: authStorage ?? AuthStorage());

  final AuthStorage _authStorage;
  final ApiClient _apiClient;

  Future<AppUser> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
    String phone,
  ) async {
    final response = await _apiClient.post(
      '/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'phone': phone,
      },
    );

    return _persistAuthResponse(response);
  }

  Future<AppUser> login(String email, String password) async {
    final response = await _apiClient.post(
      '/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    return _persistAuthResponse(response);
  }

  Future<AppUser> getCurrentUser() async {
    final response = await _apiClient.get(
      '/user',
      requiresAuth: true,
    );

    final user = AppUser.fromJson(_extractUserMap(response));
    await _authStorage.saveUser(user);
    return user;
  }

  Future<AppUser> uploadProfilePhoto(XFile photo) async {
    final response = await _apiClient.postMultipartFile(
      '/user/photo',
      fieldName: 'photo',
      file: photo,
      requiresAuth: true,
    );

    final userMap = Map<String, dynamic>.from(_extractUserMap(response));
    final data = response['data'];
    final nestedPhotoUrl =
        data is Map<String, dynamic> ? data['photo_url'] : null;
    final photoUrl = (response['photo_url'] ?? nestedPhotoUrl)?.toString();
    if (photoUrl != null && photoUrl.trim().isNotEmpty) {
      userMap['photo_url'] = photoUrl;
    }

    final cachedUser = await _authStorage.readUser();
    userMap['phone'] ??= cachedUser?.phone;

    final user = AppUser.fromJson(userMap);
    await _authStorage.saveUser(user);
    return user;
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(
        '/logout',
        body: <String, dynamic>{},
        requiresAuth: true,
      );
    } finally {
      await _authStorage.clearSession();
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _authStorage.readToken();
    return token != null && token.isNotEmpty;
  }

  Future<AppUser?> getCachedUser() {
    return _authStorage.readUser();
  }

  Future<void> clearLocalSession() {
    return _authStorage.clearSession();
  }

  Future<AppUser> _persistAuthResponse(Map<String, dynamic> response) async {
    final token = _extractToken(response);
    final user = AppUser.fromJson(_extractUserMap(response));

    await _authStorage.saveToken(token);
    await _authStorage.saveUser(user);

    return user;
  }

  String _extractToken(Map<String, dynamic> response) {
    final directToken = response['token'];
    if (directToken != null && directToken.toString().isNotEmpty) {
      return directToken.toString();
    }

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      final nestedToken = data['token'];
      if (nestedToken != null && nestedToken.toString().isNotEmpty) {
        return nestedToken.toString();
      }
    }

    throw ApiException('Response auth tidak valid.');
  }

  Map<String, dynamic> _extractUserMap(Map<String, dynamic> response) {
    final directUser = response['user'];
    if (directUser is Map<String, dynamic>) {
      return directUser;
    }

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      final nestedUser = data['user'];
      if (nestedUser is Map<String, dynamic>) {
        return nestedUser;
      }

      if (data.containsKey('id') && data.containsKey('email')) {
        return data;
      }
    }

    if (response.containsKey('id') && response.containsKey('email')) {
      return response;
    }

    throw ApiException('Response user tidak valid.');
  }
}
