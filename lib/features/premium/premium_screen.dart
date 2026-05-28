import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_config.dart';
import '../../data/models/subscription_status.dart';
import '../../data/services/api_client.dart';
import '../../data/services/midtrans_snap_launcher.dart';
import '../../state/session_controller.dart';
import '../landing/welcome_screen.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with WidgetsBindingObserver {
  final Color darkBrown = const Color(0xFF5B4D41);
  final Color bgCream = const Color(0xFFFFF8F0);
  final Color textLight = const Color(0xFF9E8E78);
  final Color gold = const Color(0xFFD8B36A);

  final MidtransSnapLauncher _snapLauncher = MidtransSnapLauncher();
  bool _didOpenPayment = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshSubscription();
      _loadPayments();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _didOpenPayment) {
      _didOpenPayment = false;
      _refreshSubscription();
      _loadPayments();
    }
  }

  Future<void> _refreshSubscription() {
    return context
        .read<SessionController>()
        .refreshSubscription(allowFailure: true);
  }

  Future<void> _loadPayments() async {
    try {
      await context.read<SessionController>().loadSubscriptionPayments();
    } on ApiException {
      // Payment history is secondary to the main subscription state.
    }
  }

  Future<void> _handlePrimaryAction() async {
    final session = context.read<SessionController>();
    final pendingPayment = session.subscription?.pendingPayment;

    try {
      late final SubscriptionPayment payment;
      if (pendingPayment != null) {
        if (!pendingPayment.canOpenPayment) {
          _showMessage('Pembayaran pending tidak memiliki Snap token.');
          return;
        }

        payment = pendingPayment;
      } else {
        payment = await session.upgradePremium(
          returnUrl: AppConfig.paymentReturnUrl,
        );
      }

      _didOpenPayment = true;
      await _snapLauncher.openPayment(payment);
      await _refreshSubscription();
      await _loadPayments();
    } on UnauthorizedException {
      _redirectToLogin();
    } on ApiException catch (e) {
      _showMessage(e.message);
    }
  }

  Future<void> _handleCancelPayment() async {
    final session = context.read<SessionController>();
    final pendingPayment = session.subscription?.pendingPayment;
    final orderId = pendingPayment?.orderId;

    if (orderId == null || orderId.isEmpty) {
      _showMessage('Order pembayaran pending tidak valid.');
      return;
    }

    try {
      await session.cancelPendingPayment(orderId);
      await _loadPayments();
      _showMessage('Pembayaran pending dibatalkan.');
    } on UnauthorizedException {
      _redirectToLogin();
    } on ApiException catch (e) {
      _showMessage(e.message);
    }
  }

  Future<void> _handleCancelSubscription() async {
    final session = context.read<SessionController>();

    try {
      await session.cancelSubscription();
      await _loadPayments();
      _showMessage('Subscription dibatalkan.');
    } on UnauthorizedException {
      _redirectToLogin();
    } on ApiException catch (e) {
      _showMessage(e.message);
    }
  }

  void _redirectToLogin() {
    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const WelcomeScreen(),
      ),
      (route) => false,
    );
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    if (!session.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _redirectToLogin();
        }
      });
    }

    final subscription = session.subscription;
    final pendingPayment = subscription?.pendingPayment;
    final isBusy = session.isLoadingSubscription ||
        session.isUpgradingSubscription ||
        session.isCancellingPayment ||
        session.isCancellingSubscription;

    return Scaffold(
      backgroundColor: const Color(0xFF9D9D9D),
      body: Stack(
        children: [
          DraggableScrollableSheet(
            initialChildSize: 0.76,
            minChildSize: 0.76,
            maxChildSize: 0.94,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                decoration: BoxDecoration(
                  color: bgCream,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: ListView(
                  controller: controller,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD2BFA9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: darkBrown,
                      child: Icon(
                        Icons.workspace_premium,
                        color: gold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'WhereToFind Premium',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _statusText(subscription),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: textLight,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _statusBadge(subscription),
                    const SizedBox(height: 22),
                    _benefit('7-day location history for you and friends'),
                    _benefit("View friends' full daily routes"),
                    _benefit('Location history export'),
                    _benefit('Priority support'),
                    const SizedBox(height: 22),
                    _priceCard(),
                    if (pendingPayment != null) ...[
                      const SizedBox(height: 14),
                      _pendingPaymentCard(pendingPayment),
                    ],
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _canUsePrimaryAction(session)
                            ? _handlePrimaryAction
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkBrown,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _primaryActionText(subscription, isBusy),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    if (pendingPayment?.isPending == true) ...[
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed:
                            session.isCancellingPayment ? null : _handleCancelPayment,
                        child: Text(
                          session.isCancellingPayment
                              ? 'Cancelling...'
                              : 'Cancel pending payment',
                          style: GoogleFonts.inter(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    if (subscription?.isPremium == true) ...[
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: session.isCancellingSubscription
                            ? null
                            : _handleCancelSubscription,
                        child: Text(
                          session.isCancellingSubscription
                              ? 'Cancelling...'
                              : 'Cancel subscription',
                          style: GoogleFonts.inter(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Payment status is always verified by backend',
                        style: GoogleFonts.inter(
                          color: textLight,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    if (session.subscriptionPayments.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _paymentHistory(session.subscriptionPayments),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  bool _canUsePrimaryAction(SessionController session) {
    if (session.isLoadingSubscription ||
        session.isUpgradingSubscription ||
        session.isCancellingPayment ||
        session.isCancellingSubscription) {
      return false;
    }

    return !(session.subscription?.isPremium ?? false);
  }

  String _statusText(SubscriptionStatus? subscription) {
    if (subscription == null) {
      return 'Checking your subscription';
    }

    if (subscription.isPremium) {
      return 'Premium active';
    }

    if (subscription.pendingPayment != null) {
      return 'You have a pending payment';
    }

    return 'Unlock the full experience';
  }

  String _primaryActionText(
    SubscriptionStatus? subscription,
    bool isBusy,
  ) {
    if (isBusy) {
      return 'Please wait...';
    }

    if (subscription?.isPremium == true) {
      return 'Premium Active';
    }

    if (subscription?.pendingPayment != null) {
      return 'Continue Payment';
    }

    return 'Subscribe Now';
  }

  Widget _statusBadge(SubscriptionStatus? subscription) {
    final String label;
    final Color background;
    final Color foreground;

    if (subscription?.isPremium == true) {
      label = 'Premium Active';
      background = const Color(0xFFD8B36A);
      foreground = Colors.black;
    } else if (subscription?.pendingPayment != null) {
      label = 'Payment Pending';
      background = const Color(0xFFFFE0B2);
      foreground = darkBrown;
    } else {
      label = 'Free Plan';
      background = const Color(0xFFF1E7DA);
      foreground = darkBrown;
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: foreground,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _benefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(Icons.check_rounded, color: gold, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgCream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2CDB7)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium Monthly',
                  style: GoogleFonts.inter(
                    color: darkBrown,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rp 19.900',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '/ month',
            style: GoogleFonts.inter(
              color: textLight,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pendingPaymentCard(SubscriptionPayment payment) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2CDB7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pending payment',
            style: GoogleFonts.inter(
              color: darkBrown,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            payment.orderId,
            style: GoogleFonts.inter(
              color: textLight,
              fontSize: 12,
            ),
          ),
          if (payment.amount != null) ...[
            const SizedBox(height: 4),
            Text(
              'Amount: Rp ${payment.amount}',
              style: GoogleFonts.inter(
                color: textLight,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _paymentHistory(List<SubscriptionPayment> payments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment History',
          style: GoogleFonts.inter(
            color: darkBrown,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: payments.take(5).map(_paymentHistoryRow).toList(),
        ),
      ],
    );
  }

  Widget _paymentHistoryRow(SubscriptionPayment payment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              payment.orderId,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: darkBrown,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            payment.paymentStatus,
            style: GoogleFonts.inter(
              color: textLight,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
