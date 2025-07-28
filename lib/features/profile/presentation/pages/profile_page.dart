import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // <-- PASTIKAN IMPOR INI ADA
import 'package:nusantara_mobile/routes/initial_routes.dart'; // <-- DAN INI JUGA

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double headerHeight = 150.0;
    const double avatarRadius = 60.0;

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: headerHeight + avatarRadius),
                _buildUserInfo(),
                const SizedBox(height: 24),
                _buildProfileCard(context), // Berikan context
                const SizedBox(height: 30),
              ],
            ),
          ),
          _buildHeader(headerHeight),
          _buildProfileAvatar(headerHeight, avatarRadius),
        ],
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

  // Widget untuk avatar profil yang tumpang tindih
  Widget _buildProfileAvatar(double headerHeight, double avatarRadius) {
    return Positioned(
      // Posisi top: tinggi header dikurangi radius avatar agar setengahnya tumpang tindih
      top: headerHeight - avatarRadius,
      // Centered horizontally
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.center,
        child: Stack(
          children: [
            CircleAvatar(
              radius: avatarRadius + 3, // Border putih
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundImage: const NetworkImage(
                  'https://i.pravatar.cc/150?img=56',
                ), // Ganti dengan gambar profil Anda
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

  // Widget untuk menampilkan nama dan email
  Widget _buildUserInfo() {
    return const Column(
      children: [
        SizedBox(height: 8),
        Text(
          'Albert Stevano Bajefski',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          'albertstevano@gmail.com',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  // Widget untuk kartu putih yang berisi menu-menu
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
              context.go(InitialRoutes.personalData);
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

  // Helper widget untuk membuat ListTile agar tidak berulang
  Widget _buildListTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap, // <-- PERUBAHAN
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap, // <-- PERUBAHAN
    );
  }
}
