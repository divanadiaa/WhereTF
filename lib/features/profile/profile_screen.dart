import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/user_avatar.dart';
import '../../data/services/api_client.dart';
import '../../state/session_controller.dart';
import '../premium/premium_screen.dart';
import '../landing/welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.showBackButton = false,
  });

  final bool? showBackButton;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color darkBrown = const Color(0xFF5B4D41);
  final Color bgCream = const Color(0xFFFFF8F0);
  final Color textLight = const Color(0xFF9E8E78);
  final Color gold = const Color(0xFFD8B36A);
  final ImagePicker _imagePicker = ImagePicker();

  static const int _maxProfilePhotoBytes = 3 * 1024 * 1024;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<SessionController>();
      session.refreshSubscription(allowFailure: true);
      session.refreshCircleMembers(allowFailure: true);
    });
  }

  Future<void> _handleLogout() async {
    final session = context.read<SessionController>();

    await session.logout();

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

  Future<void> _pickProfilePhoto() async {
    if (context.read<SessionController>().isUploadingProfilePhoto) {
      return;
    }

    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (photo == null || !mounted) {
        return;
      }

      final extension = _fileExtension(photo).toLowerCase();
      if (extension != 'jpg' && extension != 'jpeg' && extension != 'png') {
        _showBottomMessage('Format foto harus JPG, JPEG, atau PNG.');
        return;
      }

      final size = await photo.length();
      if (!mounted) {
        return;
      }

      if (size > _maxProfilePhotoBytes) {
        _showBottomMessage('Ukuran foto maksimal 3MB. Pilih foto lain.');
        return;
      }

      await context.read<SessionController>().uploadProfilePhoto(photo);

      if (!mounted) {
        return;
      }

      _showBottomMessage('Foto profil berhasil diperbarui.');
    } on UnauthorizedException {
      if (!mounted) {
        return;
      }

      _redirectToLogin();
    } on ApiValidationException catch (e) {
      if (!mounted) {
        return;
      }

      _showBottomMessage(e.message);
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }

      _showBottomMessage(e.message);
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showBottomMessage('Tidak bisa memilih foto. Coba lagi.');
    }
  }

  Future<void> _showProfilePhotoPreview() async {
    final user = context.read<SessionController>().currentUser;
    if (user == null) {
      return;
    }

    await showModalBottomSheet(
      context: context,
      backgroundColor: bgCream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return Consumer<SessionController>(
          builder: (context, session, _) {
            final currentUser = session.currentUser ?? user;
            final hasPhoto = currentUser.displayPhotoUrl != null;

            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7C2AD),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 22),
                  UserAvatar(
                    user: currentUser,
                    initials: currentUser.initials,
                    radius: 112,
                    backgroundColor: const Color(0xFFE1C9A8),
                    foregroundColor: darkBrown,
                    fontSize: 58,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    currentUser.name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: darkBrown,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hasPhoto
                        ? 'Foto profil saat ini'
                        : 'Belum ada foto profil',
                    style: GoogleFonts.inter(
                      color: textLight,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: session.isUploadingProfilePhoto
                          ? null
                          : () {
                              Navigator.pop(sheetContext);
                              _pickProfilePhoto();
                            },
                      icon: session.isUploadingProfilePhoto
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.photo_library_rounded,
                              size: 18,
                            ),
                      label: Text(
                        session.isUploadingProfilePhoto
                            ? 'Mengunggah...'
                            : 'Ganti Foto',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkBrown,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showEditProfileSheet() async {
    final user = context.read<SessionController>().currentUser;
    if (user == null) {
      return;
    }

    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phone ?? '');

    await showModalBottomSheet(
      context: context,
      backgroundColor: bgCream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return Consumer<SessionController>(
          builder: (context, session, _) {
            final currentUser = session.currentUser ?? user;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD7C2AD),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Edit Profil',
                      style: GoogleFonts.inter(
                        color: darkBrown,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _showProfilePhotoPreview();
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            UserAvatar(
                              user: currentUser,
                              initials: currentUser.initials,
                              radius: 46,
                              backgroundColor: const Color(0xFFE1C9A8),
                              foregroundColor: darkBrown,
                              fontSize: 30,
                            ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: gold,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: bgCream,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.zoom_in_rounded,
                                  color: darkBrown,
                                  size: 17,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _editField(
                      label: 'Nama',
                      controller: nameController,
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 12),
                    _editField(
                      label: 'Email',
                      controller: emailController,
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _editField(
                      label: 'Nomor Telepon',
                      controller: phoneController,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _showBottomMessage(
                            'Update nama, email, dan nomor telepon belum tersedia dari backend. Foto profil sudah bisa diganti.',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkBrown,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Simpan Perubahan',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
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

    return Scaffold(
      backgroundColor: bgCream,
      body: Column(
        children: [
          _buildHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                18,
                18,
                18,
                24,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildStats(session),

                  const SizedBox(height: 18),

                  _buildPremiumCard(),

                  const SizedBox(height: 22),

                  _sectionTitle('Akun'),
                  _accountCard(),

                  const SizedBox(height: 22),

                  _sectionTitle('Dukungan'),
                  _supportCard(),

                  const SizedBox(height: 28),

                  Center(
                    child: TextButton(
                      onPressed: session.isAuthenticating ? null : _handleLogout,
                      child: Text(
                        session.isAuthenticating ? 'Keluar...' : 'Keluar',
                        style: GoogleFonts.inter(
                          color: Colors.redAccent,
                          fontSize: 13,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final session = context.watch<SessionController>();
    final user = session.currentUser;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        48,
        20,
        24,
      ),
      decoration: BoxDecoration(
        color: darkBrown,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(26),
        ),
      ),
      child: Column(
        children: [
          if (widget.showBackButton == true) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: bgCream,
                  size: 24,
                ),
                tooltip: 'Kembali',
              ),
            ),
            const SizedBox(height: 4),
          ],
          GestureDetector(
            onTap:
                session.isUploadingProfilePhoto ? null : _showProfilePhotoPreview,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                UserAvatar(
                  user: user,
                  initials: user?.initials ?? 'P',
                  radius: 38,
                  backgroundColor: const Color(0xFFE1C9A8),
                  foregroundColor: darkBrown,
                  fontSize: 28,
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: gold,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: darkBrown,
                        width: 2,
                      ),
                    ),
                    child: session.isUploadingProfilePhoto
                        ? const Padding(
                            padding: EdgeInsets.all(7),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            Icons.zoom_in_rounded,
                            color: darkBrown,
                            size: 15,
                          ),
                  ),
                ),
              ],
            ),
          ),

          if (session.isUploadingProfilePhoto) ...[
            const SizedBox(height: 8),
            Text(
              'Mengunggah foto...',
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.72),
                fontSize: 11,
              ),
            ),
          ],

          const SizedBox(height: 10),

          Text(
            user?.name ?? 'Guest',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            user?.email ?? 'guest@example.com',
            style: GoogleFonts.inter(
              color:
                  Colors.white.withOpacity(0.72),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildStats(SessionController session) {
    final circleCount = session.currentCircle == null ? '0' : '1';
    final memberCount = session.isLoadingCircleMembers &&
            session.circleMembers.isEmpty
        ? '...'
        : session.circleMembers.length.toString();

    return Row(
      children: [
        _statCard(
          'Circles',
          circleCount,
          Icons.near_me_outlined,
        ),

        const SizedBox(width: 10),

        _statCard(
          'Members',
          memberCount,
          Icons.groups_rounded,
        ),

        const SizedBox(width: 10),

        _statCard(
          'Days Active',
          '1',
          Icons.access_time_rounded,
        ),
      ],
    );
  }

  Widget _statCard(
    String label,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: bgCream,
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE7D5C2),
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: gold,
              size: 18,
            ),

            const SizedBox(height: 5),

            Text(
              label,
              style: GoogleFonts.inter(
                color: textLight,
                fontSize: 10,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              value,
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 14,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCard() {
    final session = context.watch<SessionController>();
    final subscription = session.subscription;
    final isPremium = subscription?.isPremium ?? false;
    final hasPendingPayment = subscription?.pendingPayment != null;
    final title = isPremium
        ? 'Premium Active'
        : hasPendingPayment
            ? 'Payment Pending'
            : 'whereTF Premium';
    final subtitle = isPremium
        ? '7-day location history unlocked'
        : hasPendingPayment
            ? 'Continue or cancel your premium payment'
            : 'Unlock 7-day location history';
    final badgeColor = isPremium || hasPendingPayment ? gold : bgCream;
    final iconColor = isPremium || hasPendingPayment ? darkBrown : gold;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const PremiumScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: darkBrown,
          borderRadius:
              BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor:
                  badgeColor.withOpacity(0.22),
              child: Icon(
                Icons
                    .workspace_premium_rounded,
                color: iconColor,
                size: 24,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    session.isLoadingSubscription
                        ? 'Checking subscription status...'
                        : subtitle,
                    style: GoogleFonts.inter(
                      color: Colors.white
                          .withOpacity(0.72),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              color: bgCream,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _accountCard() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _menuTile(
            icon:
                Icons.edit_outlined,
            title: 'Edit Profil',
            onTap: _showEditProfileSheet,
          ),
        ],
      ),
    );
  }

  Widget _supportCard() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _menuTile(
            icon:
                Icons.help_outline_rounded,
            title: 'Bantuan & Dukungan',
            onTap: () {
              _showHelpSupportSheet();
            },
          ),

          _divider(),

          _menuTile(
            icon:
                Icons.info_outline_rounded,
            title: 'Tentang WhereTF?',
            onTap: () {
              _showAboutSheet();
            },
          ),
        ],
      ),
    );
  }

  Widget _editField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: gold,
          size: 20,
        ),
        labelStyle: GoogleFonts.inter(
          color: textLight,
          fontSize: 12,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.58),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE7D5C2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: gold,
            width: 1.2,
          ),
        ),
      ),
      style: GoogleFonts.inter(
        color: darkBrown,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  void _showHelpSupportSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _sheetHandle()),
              const SizedBox(height: 20),
              Text(
                'Bantuan & Dukungan',
                style: GoogleFonts.inter(
                  color: darkBrown,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              _infoItem(
                icon: Icons.location_on_outlined,
                title: 'Lokasi tidak akurat',
                subtitle:
                    'Pastikan izin lokasi aktif dan mode akurasi tinggi menyala di pengaturan perangkat.',
              ),
              _infoItem(
                icon: Icons.group_outlined,
                title: 'Circle atau member belum muncul',
                subtitle:
                    'Tarik untuk refresh atau buka ulang halaman setelah join atau leave circle berhasil.',
              ),
              _infoItem(
                icon: Icons.wifi_off_rounded,
                title: 'Tidak bisa terhubung ke server',
                subtitle:
                    'Periksa koneksi internet, lalu coba lagi beberapa saat lagi.',
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showAboutSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _sheetHandle()),
              const SizedBox(height: 20),
              Text(
                'WhereTF?',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: darkBrown,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'WhereToFind?',
                style: GoogleFonts.inter(
                  color: gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'WhereTF? adalah aplikasi berbagi lokasi untuk membantu keluarga, teman, atau circle terpercaya saling mengetahui posisi dengan lebih mudah.',
                style: GoogleFonts.inter(
                  color: textLight,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Aplikasi ini berfokus pada circle privat, status member, lokasi real-time, dan fitur premium seperti riwayat lokasi.',
                style: GoogleFonts.inter(
                  color: textLight,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'WhereTF? terus dikembangkan agar pengalaman berbagi lokasi terasa lebih aman, jelas, dan ringan dipakai sehari-hari.',
                style: GoogleFonts.inter(
                  color: darkBrown,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: gold.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: darkBrown,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: darkBrown,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: textLight,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sheetHandle() {
    return Container(
      width: 42,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFD7C2AD),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 2,
      ),
      leading: Icon(
        icon,
        color: gold,
        size: 20,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: darkBrown,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: textLight,
        size: 14,
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 2,
        bottom: 10,
      ),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          color:
              darkBrown.withOpacity(0.75),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: bgCream,
      borderRadius:
          BorderRadius.circular(14),
      border: Border.all(
        color: const Color(0xFFE7D5C2),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: const Color(0xFFE7D5C2),
      indent: 48,
    );
  }

  void _showBottomMessage(String text) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: darkBrown,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }

  String _fileExtension(XFile file) {
    final name = file.name.trim().isNotEmpty ? file.name : file.path;
    final lastSegment = name.split(RegExp(r'[\\/]')).last;
    final dotIndex = lastSegment.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == lastSegment.length - 1) {
      return '';
    }

    return lastSegment.substring(dotIndex + 1);
  }

  void _redirectToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const WelcomeScreen(),
      ),
      (route) => false,
    );
  }
}
