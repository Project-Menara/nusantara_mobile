import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_event.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:nusantara_mobile/features/profile/presentation/widgets/confirmation_dialog.dart';
import 'package:nusantara_mobile/features/profile/presentation/pages/profil/terms_and_conditions_page.dart';
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
    // debug: 📱 ProfilePage: initState called

    final authBloc = context.read<AuthBloc>();
    // debug: 📱 ProfilePage: AuthBloc instance hashCode: ${authBloc.hashCode}

    final currentState = authBloc.state;
    // debug: 📱 ProfilePage: Current AuthBloc state: ${currentState.runtimeType}
    // debug: 📱 ProfilePage: Current user: ${currentState.user?.name ?? 'null'}
    // debug: 📱 ProfilePage: Is loading: ${currentState is AuthGetProfileLoading}

    // If the user is unauthenticated (guest), redirect to login screen instead
    // of trying to send events to a possibly closed bloc.
    if (currentState is AuthUnauthenticated || currentState.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(InitialRoutes.loginScreen);
      });
      return;
    }

    // Only request status check when appropriate and when bloc is open
    if ((currentState is AuthInitial) &&
        currentState is! AuthGetProfileLoading &&
        authBloc.isClosed == false) {
      authBloc.add(AuthCheckStatusRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // debug: 📱 ProfilePage: Listener - AuthBloc instance hashCode: ${authBloc.hashCode}
        // debug: 📱 ProfilePage: State changed to ${state.runtimeType}

        if (state is AuthUnauthenticated) {
          // debug: 📱 ProfilePage: User unauthenticated, navigating to login
          context.go(InitialRoutes.loginScreen);
        } else if (state is AuthLogoutFailure) {
          // debug: 📱 ProfilePage: Logout failed: ${state.message}
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal Logout: ${state.message}')),
          );
        } else if (state is AuthGetUserSuccess) {
          // debug: 📱 ProfilePage: User data loaded successfully: ${state.user.name}
        } else if (state is AuthGetProfileLoading) {
          // debug: 📱 ProfilePage: Profile loading...
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          // debug: 📱 ProfilePage: Builder - AuthBloc instance hashCode: ${authBloc.hashCode}
          // debug: 📱 ProfilePage: Building UI with state: ${authState.runtimeType}

          final user = authState.user;

          final bool isLoading = authState is AuthGetProfileLoading;
          final bool hasError =
              authState is AuthUnauthenticated && user == null;

          final displayUser = user ?? const UserEntity.empty();

          // debug: 📱 ProfilePage: isLoading: $isLoading
          // debug: 📱 ProfilePage: hasError: $hasError
          // debug: 📱 ProfilePage: user: ${user?.name ?? 'null'}
          // debug: 📱 ProfilePage: displayUser: ${displayUser.name}

          if (hasError && !isLoading) {
            return Scaffold(
              backgroundColor: const Color(0xFFF0F2F5),
              appBar: _buildAppBar(context),
              body: _buildErrorContent(context),
            );
          }

          return Scaffold(
            backgroundColor: const Color(0xFFF0F2F5),
            appBar: _buildAppBar(context),
            body: RefreshIndicator(
              onRefresh: () async {
                // debug: 📱 ProfilePage: Refresh triggered
                context.read<AuthBloc>().add(AuthCheckStatusRequested());
              },
              child: _buildProfileContent(context, displayUser, isLoading),
            ),
          );
        },
      ),
    );
  }

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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.orange,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      centerTitle: true,
      automaticallyImplyLeading: false, // Hapus tombol kembali default
      title: Text(
        'Profile',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
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
        backgroundColor: Colors.transparent,
        child: ClipOval(
          child: Image.network(
            photoUrl,
            width: avatarRadius * 2,
            height: avatarRadius * 2,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildInitialsAvatar(user.name),
          ),
        ),
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontSize: 14, color: Colors.grey),
        ),
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
          Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 8),
            child: Text(
              'Akun',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
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
          Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 8),
            child: Text(
              'Keamanan & Bantuan',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
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
          _buildListTile(
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (ctx) => const TermsAndConditionsPage(),
                ),
              );
            },
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
                  final b = context.read<AuthBloc>();
                  if (!b.isClosed) b.add(AuthLogoutRequested());
                }
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: Text(
                'Sign Out',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
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

  // TAMBAHAN: Method untuk menampilkan error state
  Widget _buildErrorContent(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Profile',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Terjadi kesalahan saat memuat data profile. Silakan coba lagi.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // debug: 📱 ProfilePage: Retry button pressed
                final b = context.read<AuthBloc>();
                if (!b.isClosed) b.add(AuthCheckStatusRequested());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
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
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
