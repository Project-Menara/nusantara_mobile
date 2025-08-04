import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// <<< PERBAIKAN: Cukup impor satu file dialog reusable untuk semua konfirmasi >>>
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_event.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:nusantara_mobile/features/profile/presentation/widgets/change_pin_confirmation_dialog.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';

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
    if (currentState is! AuthLoginSuccess &&
        currentState is! AuthGetUserSuccess &&
        currentState is! AuthUpdateSuccess) {
      context.read<AuthBloc>().add(AuthCheckStatusRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = 150.0;
    const double avatarRadius = 60.0;

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
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<AuthBloc>().add(AuthCheckStatusRequested());
          },
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: headerHeight + avatarRadius),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is AuthGetProfileLoading ||
                            state is AuthInitial) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        UserEntity? user;
                        if (state is AuthLoginSuccess) {
                          user = state.user;
                        } else if (state is AuthGetUserSuccess) {
                          user = state.user;
                        } else if (state is AuthUpdateSuccess) {
                          user = state.user;
                        }

                        if (user != null) {
                          return _buildUserInfo(
                            name: user.name,
                            email: user.email,
                          );
                        }

                        return _buildUserInfo(
                          name: 'Gagal memuat',
                          email: 'Tarik untuk refresh',
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildProfileCard(context),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              _buildHeader(headerHeight),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  UserEntity? user;
                  if (state is AuthLoginSuccess) {
                    user = state.user;
                  } else if (state is AuthGetUserSuccess) {
                    user = state.user;
                  } else if (state is AuthUpdateSuccess) {
                    user = state.user;
                  }

                  return _buildProfileAvatar(
                    headerHeight,
                    avatarRadius,
                    user?.photo,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double height) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      child: Container(
        height: height,
        width: double.infinity,
        color: Colors.red.shade700,
        child: const SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(
    double headerHeight,
    double avatarRadius,
    String? photoUrl,
  ) {
    final bool hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
    return Positioned(
      top: headerHeight - avatarRadius,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.center,
        child: CircleAvatar(
          radius: avatarRadius + 3,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: avatarRadius,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
            child: !hasPhoto
                ? Icon(
                    Icons.person,
                    size: avatarRadius * 1.2,
                    color: Colors.white,
                  )
                : null,
          ),
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
      margin: const EdgeInsets.symmetric(horizontal: 24),
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
            child: Text('Profile', style: TextStyle(color: Colors.grey)),
          ),
          _buildListTile(
            icon: Icons.person_outline,
            title: 'Personal Data',
            onTap: () {
              context.push(InitialRoutes.personalData);
            },
          ),
          _buildListTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {},
          ),
          _buildListTile(
            icon: Icons.confirmation_number_outlined,
            title: 'My Voucher',
            onTap: () {},
          ),
          const Divider(indent: 24, endIndent: 24, height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 24, bottom: 8),
            child: Text('Support', style: TextStyle(color: Colors.grey)),
          ),
          _buildListTile(
            icon: Icons.support_agent_outlined,
            title: 'Layanan Pelanggan',
            onTap: () {},
          ),
          _buildListTile(
            icon: Icons.delete_outline,
            title: 'Request Account Deletion',
            onTap: () {},
          ),
          _buildListTile(
            icon: Icons.lock_outline,
            title: 'Ubah Pin',
            onTap: () {
              // Memanggil helper spesifik yang bersih
              showChangePinConfirmationDialog(context);
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OutlinedButton.icon(
              onPressed: () async {
                // <<< PERBAIKAN: Gunakan dialog konfirmasi generic untuk logout >>>
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
