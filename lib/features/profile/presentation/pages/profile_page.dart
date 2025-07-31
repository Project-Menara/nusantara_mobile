import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // --- PERUBAHAN: Tambah import BLoC ---
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart'; // --- PERUBAHAN: Tambah import AuthBloc ---
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_event.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double headerHeight = 150.0;
    const double avatarRadius = 60.0;

    // --- PERUBAHAN: Bungkus dengan BlocListener untuk handle navigasi logout ---
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // Jika state menjadi Unauthenticated (setelah logout), kembali ke login
          context.go(InitialRoutes.loginScreen);
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
                  // --- PERUBAHAN: Gunakan BlocBuilder untuk menampilkan data user ---
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoginSuccess) {
                        // Jika login berhasil, tampilkan data user
                        return _buildUserInfo(
                          name: state.user.name,
                          email: state.user.email,
                        );
                      }
                      // Tampilkan placeholder atau loading jika data belum siap
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
            // --- PERUBAHAN: Gunakan BlocBuilder untuk menampilkan foto profil ---
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                String? photoUrl;
                if (state is AuthLoginSuccess) {
                  photoUrl = state.user.photo;
                }
                return _buildProfileAvatar(
                  headerHeight,
                  avatarRadius,
                  photoUrl,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double height) {
    // ... (kode ini tidak berubah)
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

  // --- PERUBAHAN: Terima URL foto sebagai parameter ---
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
                // --- PERUBAHAN: Gunakan gambar dari network jika ada, jika tidak, gunakan default ---
                backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                    ? NetworkImage(photoUrl)
                    : const NetworkImage('https://i.pravatar.cc/150?img=56')
                          as ImageProvider,
              ),
            ),
            // ... (Ikon kamera tetap sama)
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

  // --- PERUBAHAN: Terima nama dan email sebagai parameter ---
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
    // Terima context
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
          // MODIFIKASI DI SINI
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
                // Logika Sign Out
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
    // ... (kode ini tidak berubah)
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
