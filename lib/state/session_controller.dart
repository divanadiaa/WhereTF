import 'package:flutter/material.dart';

import '../data/models/app_user.dart';
import '../data/models/circle_summary.dart';
import '../data/models/subscription_status.dart';
import '../data/services/api_client.dart';
import '../data/services/auth_service.dart';
import '../data/services/auth_storage.dart';
import '../data/services/circle_service.dart';
import '../data/services/subscription_service.dart';

class SessionController extends ChangeNotifier {
  SessionController({
    AuthService? authService,
    CircleService? circleService,
    SubscriptionService? subscriptionService,
    AuthStorage? authStorage,
  })  : _authService = authService ?? AuthService(),
        _circleService = circleService ?? CircleService(),
        _subscriptionService = subscriptionService ?? SubscriptionService(),
        _authStorage = authStorage ?? AuthStorage();

  final AuthService _authService;
  final CircleService _circleService;
  final SubscriptionService _subscriptionService;
  final AuthStorage _authStorage;

  AppUser? _currentUser;
  CircleSummary? _currentCircle;
  SubscriptionStatus? _subscription;
  List<SubscriptionPayment> _subscriptionPayments =
      const <SubscriptionPayment>[];
  bool _isBootstrapping = false;
  bool _isAuthenticating = false;
  bool _isUpdatingCircle = false;
  bool _isLoadingSubscription = false;
  bool _isUpgradingSubscription = false;
  bool _isCancellingPayment = false;
  bool _isCancellingSubscription = false;
  String? _subscriptionError;

  AppUser? get currentUser => _currentUser;
  CircleSummary? get currentCircle => _currentCircle;
  SubscriptionStatus? get subscription => _subscription;
  List<SubscriptionPayment> get subscriptionPayments =>
      List.unmodifiable(_subscriptionPayments);
  bool get isLoggedIn => _currentUser != null;
  bool get isBootstrapping => _isBootstrapping;
  bool get isAuthenticating => _isAuthenticating;
  bool get isUpdatingCircle => _isUpdatingCircle;
  bool get isLoadingSubscription => _isLoadingSubscription;
  bool get isUpgradingSubscription => _isUpgradingSubscription;
  bool get isCancellingPayment => _isCancellingPayment;
  bool get isCancellingSubscription => _isCancellingSubscription;
  String? get subscriptionError => _subscriptionError;
  bool get isPremium => _subscription?.isPremium ?? false;
  bool get canLeaveCurrentCircle =>
      _currentCircle != null &&
      _currentUser != null &&
      !_currentCircle!.isOwnedBy(_currentUser!.id);

  Future<bool> bootstrap() async {
    if (_isBootstrapping) {
      return isLoggedIn;
    }

    _isBootstrapping = true;
    notifyListeners();

    try {
      final cachedUser = await _authService.getCachedUser();
      final cachedCircle = await _authStorage.readCurrentCircle();
      if (cachedUser != null) {
        _currentUser = cachedUser;
      }
      _currentCircle = cachedCircle;
      notifyListeners();

      final hasToken = await _authService.isLoggedIn();
      if (!hasToken) {
        _currentUser = null;
        _currentCircle = null;
        _clearSubscriptionState();
        return false;
      }

      final user = await _authService.getCurrentUser();
      _currentUser = user;
      await refreshSubscription(allowFailure: true);
      return true;
    } on UnauthorizedException {
      await _authService.clearLocalSession();
      _clearSessionState();
      return false;
    } on ApiException {
      _currentUser = null;
      _clearSubscriptionState();
      return false;
    } finally {
      _isBootstrapping = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isAuthenticating = true;
    notifyListeners();

    try {
      final user = await _authService.login(email, password);
      _currentUser = user;
      await refreshSubscription(allowFailure: true);
      notifyListeners();
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
    String phone,
  ) async {
    _isAuthenticating = true;
    notifyListeners();

    try {
      final user = await _authService.register(
        name,
        email,
        password,
        passwordConfirmation,
        phone,
      );
      _currentUser = user;
      await refreshSubscription(allowFailure: true);
      notifyListeners();
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (_isAuthenticating) {
      return;
    }

    _isAuthenticating = true;
    notifyListeners();

    try {
      await _authService.logout();
    } on ApiException {
      // Local session is still cleared by the auth service.
    } finally {
      _clearSessionState();
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  Future<String> joinCircle(String referalCode) async {
    if (_isUpdatingCircle) {
      return '';
    }

    _isUpdatingCircle = true;
    notifyListeners();

    try {
      final result = await _circleService.joinCircle(referalCode);
      _currentCircle = result.circle;
      await _authStorage.saveCurrentCircle(result.circle);
      notifyListeners();
      return result.message;
    } finally {
      _isUpdatingCircle = false;
      notifyListeners();
    }
  }

  Future<String> leaveCircle() async {
    if (_isUpdatingCircle) {
      return '';
    }

    _isUpdatingCircle = true;
    notifyListeners();

    try {
      final result = await _circleService.leaveCircle();
      _currentCircle = result.circle;
      await _authStorage.saveCurrentCircle(result.circle);
      notifyListeners();
      return result.message;
    } finally {
      _isUpdatingCircle = false;
      notifyListeners();
    }
  }

  Future<void> refreshSubscription({bool allowFailure = false}) async {
    if (_isLoadingSubscription) {
      return;
    }

    _isLoadingSubscription = true;
    _subscriptionError = null;
    notifyListeners();

    try {
      _subscription = await _subscriptionService.getSubscription();
    } on UnauthorizedException {
      await _handleUnauthorized();
      if (!allowFailure) {
        rethrow;
      }
    } on ApiException catch (e) {
      _subscriptionError = e.message;
      if (!allowFailure) {
        rethrow;
      }
    } finally {
      _isLoadingSubscription = false;
      notifyListeners();
    }
  }

  Future<SubscriptionPayment> upgradePremium({
    String? returnUrl,
  }) async {
    if (_isUpgradingSubscription) {
      final pendingPayment = _subscription?.pendingPayment;
      if (pendingPayment != null) {
        return pendingPayment;
      }
    }

    _isUpgradingSubscription = true;
    _subscriptionError = null;
    notifyListeners();

    try {
      final payment = await _subscriptionService.upgradeToPremium(
        returnUrl: returnUrl,
      );
      await refreshSubscription(allowFailure: true);
      return payment;
    } on UnauthorizedException {
      await _handleUnauthorized();
      rethrow;
    } on ApiException catch (e) {
      _subscriptionError = e.message;
      rethrow;
    } finally {
      _isUpgradingSubscription = false;
      notifyListeners();
    }
  }

  Future<void> loadSubscriptionPayments() async {
    try {
      _subscriptionPayments = await _subscriptionService.getPayments();
      notifyListeners();
    } on UnauthorizedException {
      await _handleUnauthorized();
      rethrow;
    }
  }

  Future<void> cancelPendingPayment(String orderId) async {
    if (_isCancellingPayment) {
      return;
    }

    _isCancellingPayment = true;
    _subscriptionError = null;
    notifyListeners();

    try {
      await _subscriptionService.cancelPendingPayment(orderId);
      await refreshSubscription(allowFailure: true);
    } on UnauthorizedException {
      await _handleUnauthorized();
      rethrow;
    } on ApiException catch (e) {
      _subscriptionError = e.message;
      rethrow;
    } finally {
      _isCancellingPayment = false;
      notifyListeners();
    }
  }

  Future<void> cancelSubscription() async {
    if (_isCancellingSubscription) {
      return;
    }

    _isCancellingSubscription = true;
    _subscriptionError = null;
    notifyListeners();

    try {
      await _subscriptionService.cancelSubscription();
      await refreshSubscription(allowFailure: true);
    } on UnauthorizedException {
      await _handleUnauthorized();
      rethrow;
    } on ApiException catch (e) {
      _subscriptionError = e.message;
      rethrow;
    } finally {
      _isCancellingSubscription = false;
      notifyListeners();
    }
  }

  Future<void> _handleUnauthorized() async {
    await _authService.clearLocalSession();
    _clearSessionState();
    notifyListeners();
  }

  void _clearSessionState() {
    _currentUser = null;
    _currentCircle = null;
    _clearSubscriptionState();
  }

  void _clearSubscriptionState() {
    _subscription = null;
    _subscriptionPayments = const <SubscriptionPayment>[];
    _subscriptionError = null;
  }
}
