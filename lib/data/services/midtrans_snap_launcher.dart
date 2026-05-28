import 'package:url_launcher/url_launcher.dart';

import '../../core/config/app_config.dart';
import '../models/subscription_status.dart';
import 'api_client.dart';

class MidtransSnapLauncher {
  Future<void> openPayment(SubscriptionPayment payment) async {
    final uri = _buildPaymentUri(payment);

    final bool didLaunch;
    try {
      didLaunch = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      throw ApiException('Tidak bisa membuka halaman pembayaran.');
    }

    if (!didLaunch) {
      throw ApiException('Tidak bisa membuka halaman pembayaran.');
    }
  }

  Uri _buildPaymentUri(SubscriptionPayment payment) {
    final redirectUrl = payment.redirectUrl;
    if (redirectUrl != null && redirectUrl.isNotEmpty) {
      return Uri.parse(redirectUrl);
    }

    final snapToken = payment.snapToken;
    if (snapToken == null || snapToken.isEmpty) {
      throw ApiException('Snap token pembayaran tidak tersedia.');
    }

    return Uri.parse('${AppConfig.midtransSnapBaseUrl}/$snapToken');
  }
}
