import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_event.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:nusantara_mobile/features/profile/presentation/widgets/confirmation_dialog.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    final currentState = context.read<AuthBloc>().state;
    if (currentState.user == null && currentState is! AuthGetProfileLoading) {
      context.read<AuthBloc>().add(AuthCheckStatusRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(InitialRoutes.loginScreen);
        } else if (state is AuthLogoutFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal Logout: ${state.message}')),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user = authState.user;
          final bool isLoading =
              authState is AuthGetProfileLoading || user == null;
          final displayUser = user ?? const UserEntity.empty();

          return Scaffold(
            // <<< PERUBAHAN: Ganti warna background dan gunakan AppBar biasa >>>
            backgroundColor: const Color(0xFFF0F2F5),
            appBar: _buildAppBar(),
            body: RefreshIndicator(
              onRefresh: isLoading
                  ? () async {}
                  : () async {
                      context.read<AuthBloc>().add(AuthCheckStatusRequested());
                    },
              // <<< PERUBAHAN: Body tidak lagi menggunakan Stack >>>
              child: _buildProfileContent(context, displayUser, isLoading),
            ),
          );
        },
      ),
    );
  }

  // <<< PERBAIKAN TOTAL: Struktur layout diubah menjadi Column sederhana >>>
  Widget _buildProfileContent(
    BuildContext context,
    UserEntity user,
    bool isLoading,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Skeletonizer(
        enabled: isLoading,
        child: Column(
          children: [
            _buildProfileAvatar(user),
            const SizedBox(height: 16),
            _buildUserInfo(name: user.name, email: user.email),
            const SizedBox(height: 24),
            _buildProfileCard(context),
          ],
        ),
      ),
    );
  }

  // <<< PERBAIKAN: AppBar dibuat terpisah seperti di PersonalDataPage >>>
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.red.shade700,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false, // Hapus tombol kembali default
      title: const Text(
        'Profile',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(20.0), // Tinggi "bayangan" bawah
        child: Container(),
      ),
    );
  }

  // <<< PERBAIKAN: Avatar tidak lagi di dalam Stack/Positioned >>>
  Widget _buildProfileAvatar(UserEntity user) {
    const double avatarRadius = 60.0;
    final photoUrl = user.photo;

    Widget avatarChild;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      avatarChild = CircleAvatar(
        radius: avatarRadius,
        backgroundImage: NetworkImage(photoUrl),
      );
    } else {
      // Fallback ke inisial nama
      avatarChild = _buildInitialsAvatar(user.name);
    }

    return SizedBox(
      width: (avatarRadius * 2) + 10,
      height: (avatarRadius * 2) + 10,
      child: Stack(
        children: [
          Center(
            child: CircleAvatar(
              radius: avatarRadius + 3,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              child: avatarChild,
            ),
          ),
        ],
      ),
    );
  }

  // <<< BARU: Helper untuk avatar inisial >>>
  Widget _buildInitialsAvatar(String fullName) {
    String getInitials(String name) {
      if (name.trim().isEmpty) return '?';
      List<String> names = name.trim().split(' ');
      String initials = names[0].isNotEmpty ? names[0][0] : '';
      if (names.length > 1 && names.last.isNotEmpty) {
        initials += names.last[0];
      }
      return initials.toUpperCase();
    }

    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.orange.shade700,
      child: Text(
        getInitials(fullName),
        style: const TextStyle(
          fontSize: 40,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUserInfo({required String name, required String email}) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(email, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      // margin dihapus karena sudah diatur oleh padding di SingleChildScrollView
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 24, bottom: 8),
            child: Text('Akun', style: TextStyle(color: Colors.grey)),
          ),
          _buildListTile(
            icon: Icons.person_outline,
            title: 'Personal Data',
            onTap: () {
              context.push(InitialRoutes.personalData);
            },
          ),
          _buildListTile(
            icon: Icons.card_giftcard,
            title: 'My Vouchers',
            onTap: () {
              context.push(InitialRoutes.myVouchers);
            },
          ),
          const Divider(indent: 24, endIndent: 24, height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 24, bottom: 8),
            child: Text(
              'Keamanan & Bantuan',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          _buildListTile(
            icon: Icons.lock_outline,
            title: 'Ubah Pin',
            onTap: () {
              showChangePinConfirmationDialog(context);
            },
          ),
          _buildListTile(
            icon: Icons.support_agent_outlined,
            title: 'Layanan Pelanggan',
            onTap: () {},
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showConfirmationDialog(
                  context: context,
                  title: 'Konfirmasi Keluar',
                  content: 'Apakah Anda yakin ingin keluar dari akun Anda?',
                  confirmText: 'Ya, Keluar',
                  confirmButtonColor: Colors.red,
                  icon: Icons.logout_rounded,
                );
                if (confirmed == true && context.mounted) {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                }
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
