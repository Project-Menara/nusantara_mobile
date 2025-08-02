import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_event.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_state.dart';
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
    // Cek state yang ada saat ini di BLoC.
    // Panggil API HANYA jika state belum memiliki data user.
    final currentState = context.read<AuthBloc>().state;
    if (currentState is! AuthLoginSuccess &&
        currentState is! AuthGetUserSuccess) {
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
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: headerHeight + avatarRadius),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      // Tambahkan pengecekan untuk state loading awal
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
                      }

                      if (user != null) {
                        return _buildUserInfo(
                          name: user.name,
                          email: user.email,
                        );
                      }

                      return _buildUserInfo(name: 'Loading...', email: '...');
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
    return Positioned(
      top: headerHeight - avatarRadius,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.center,
        child: Stack(
          children: [
            CircleAvatar(
              radius: avatarRadius + 3,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                    ? NetworkImage(photoUrl)
                    : const NetworkImage('https://i.pravatar.cc/150?img=56')
                          as ImageProvider,
              ),
            ),
            Positioned(
              bottom: 5,
              right: 5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ],
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
            onTap: () {
              /* Navigasi untuk Settings */
            },
          ),
          _buildListTile(
            icon: Icons.confirmation_number_outlined,
            title: 'My Voucher',
            onTap: () {
              /* Navigasi untuk Voucher */
            },
          ),
          const Divider(indent: 24, endIndent: 24, height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 24, bottom: 8),
            child: Text('Support', style: TextStyle(color: Colors.grey)),
          ),
          _buildListTile(
            icon: Icons.support_agent_outlined,
            title: 'Layanan Pelanggan',
            onTap: () {
              /* Navigasi */
            },
          ),
          _buildListTile(
            icon: Icons.delete_outline,
            title: 'Request Account Deletion',
            onTap: () {
              /* Navigasi */
            },
          ),
          _buildListTile(
            icon: Icons.lock_outline,
            title: 'Ubah Pin',
            onTap: () {
              /* Navigasi */
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      title: const Text('Konfirmasi'),
                      content: const Text('Apakah Anda yakin ingin keluar?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Batal'),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Ya, Keluar'),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            context.read<AuthBloc>().add(AuthLogoutRequested());
                          },
                        ),
                      ],
                    );
                  },
                );
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
