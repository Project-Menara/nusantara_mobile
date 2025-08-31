import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nusantara_mobile/core/helper/flashbar_helper.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_event.dart'
    as auth_event;
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:nusantara_mobile/features/profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:nusantara_mobile/features/profile/presentation/widgets/confirmation_dialog.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PersonalDataPage extends StatelessWidget {
  const PersonalDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PersonalDataView();
  }
}

class PersonalDataView extends StatefulWidget {
  const PersonalDataView({super.key});

  @override
  State<PersonalDataView> createState() => _PersonalDataViewState();
}

class _PersonalDataViewState extends State<PersonalDataView> {
  final _fullNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  String? _selectedGender;
  final List<String> _genders = ['Laki-laki', 'Perempuan'];
  bool _isEditMode = false;
  File? _photoFile;

  @override
  void initState() {
    super.initState();
    final initialUser = context.read<AuthBloc>().state.user;
    _populateControllers(initialUser);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _populateControllers(UserEntity? user) {
    if (user != null && user.id != 0) {
      _fullNameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
      _selectedGender = (user.gender == 'Male' || user.gender == 'Laki-laki')
          ? 'Laki-laki'
          : 'Perempuan';
      if (user.dateOfBirth != null) {
        _dobController.text = DateFormat(
          'dd/MM/yyyy',
        ).format(user.dateOfBirth!);
      } else {
        _dobController.text = '';
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate;
    try {
      initialDate = _dobController.text.isNotEmpty
          ? DateFormat('dd/MM/yyyy').parse(_dobController.text)
          : DateTime.now();
    } catch (e) {
      initialDate = DateTime.now();
    }
    final lastDate = DateTime.now();
    if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: lastDate,
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _pickImage() async {
    if (!_isEditMode) return;
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() {
        _photoFile = File(image.path);
      });
    }
  }

  void _onSaveChanges(UserEntity? currentUser) {
    if (currentUser == null) return;
    DateTime? newDob;
    if (_dobController.text.isNotEmpty) {
      try {
        newDob = DateFormat('dd/MM/yyyy').parse(_dobController.text);
      } catch (e) {
        showAppFlashbar(
          context,
          title: "Format Tanggal Salah",
          message: "Silakan periksa kembali tanggal lahir Anda.",
          isSuccess: false,
        );
        return;
      }
    }
    final updatedData = currentUser.copyWith(
      name: _fullNameController.text,
      gender: _selectedGender,
      dateOfBirth: newDob,
    );
    context.read<ProfileBloc>().add(
      UpdateProfileButtonPressed(user: updatedData, photoFile: _photoFile),
    );
  }

  void _startChangePhoneFlow() async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Ubah Nomor Telepon',
      content:
          'Anda akan memulai proses untuk mengubah nomor telepon Anda. Aksi ini memerlukan verifikasi PIN.',
      confirmText: 'Lanjutkan',
      confirmButtonColor: Colors.orange.shade700,
      icon: Icons.phonelink_setup_rounded,
    );

    if (confirmed == true && context.mounted) {
      context.push(InitialRoutes.verifyPinForChangePhone);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState.user;

        // <<< PERBAIKAN 1: Logika isLoading diperbarui >>>
        // Skeleton aktif saat loading awal (user==null) ATAU saat state refresh (AuthGetProfileLoading)
        final bool isLoading =
            authState is AuthGetProfileLoading || user == null;

        final displayUser = user ?? const UserEntity.empty();

        return Scaffold(
          backgroundColor: const Color(0xFFF0F2F5),
          appBar: _buildAppBar(),
          body: MultiBlocListener(
            listeners: [
              BlocListener<ProfileBloc, ProfileState>(
                listener: (context, state) {
                  if (state is ProfileUpdateSuccess) {
                    context.read<AuthBloc>().add(
                      auth_event.AuthUserUpdated(state.updatedUser),
                    );
                    showAppFlashbar(
                      context,
                      title: "Sukses",
                      message: "Profil berhasil diperbarui.",
                      isSuccess: true,
                    );
                    setState(() {
                      _isEditMode = false;
                      _photoFile = null;
                    });
                  } else if (state is ProfileUpdateFailure) {
                    showAppFlashbar(
                      context,
                      title: "Gagal",
                      message: state.message,
                      isSuccess: false,
                    );
                  }
                },
              ),
              BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthUpdateSuccess) {
                    _populateControllers(state.user);
                  }
                },
              ),
            ],
            // Kirim state `isLoading` ke `_buildContent`
            child: _buildContent(context, displayUser, isLoading),
          ),
          bottomNavigationBar: Skeletonizer(
            enabled: isLoading,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                8,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: _buildActionButtons(displayUser),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, UserEntity user, bool isLoading) {
    // <<< PERBAIKAN 2: Bungkus konten dengan RefreshIndicator >>>
    return RefreshIndicator(
      onRefresh: () async {
        // Memicu event untuk mengambil ulang data profil
        context.read<AuthBloc>().add(auth_event.AuthCheckStatusRequested());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Skeletonizer(
          enabled: isLoading,
          child: Column(
            children: [
              _buildProfileAvatar(user),
              const SizedBox(height: 24),
              _buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  // Sisa kode tidak berubah...
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.orange,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      centerTitle: true,
      title: const Text(
        'Profile Settings',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(UserEntity user) {
    const double avatarRadius = 60.0;
    final photoUrl = user.photo;

    Widget avatarChild;
    if (_photoFile != null) {
      avatarChild = CircleAvatar(
        radius: avatarRadius,
        backgroundImage: FileImage(_photoFile!),
      );
    } else if (photoUrl != null && photoUrl.isNotEmpty) {
      avatarChild = CircleAvatar(
        radius: avatarRadius,
        backgroundImage: NetworkImage(photoUrl),
      );
    } else {
      avatarChild = _buildInitialsAvatar(user.name);
    }

    return GestureDetector(
      onTap: _pickImage,
      child: SizedBox(
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
            if (_isEditMode)
              Positioned(
                right: 0,
                bottom: 0,
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.orange,
                    child: Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            label: 'Full Name',
            controller: _fullNameController,
            readOnly: !_isEditMode,
          ),
          const SizedBox(height: 16),
          _buildDateField(
            label: 'Date of birth',
            controller: _dobController,
            onTap: _isEditMode ? () => _selectDate(context) : null,
          ),
          const SizedBox(height: 16),
          _buildGenderDropdown(),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Phone',
            controller: _phoneController,
            readOnly: true,
            onTap: _isEditMode ? _startChangePhoneFlow : null,
            suffixIcon: _isEditMode
                ? const Icon(Icons.chevron_right, color: Colors.grey)
                : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Email',
            controller: _emailController,
            readOnly: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF616161),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly ? const Color(0xFFEEEEEE) : Colors.white,
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: onTap != null ? Colors.orange : Colors.orange,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF616161),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          style: const TextStyle(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: onTap != null ? Colors.white : const Color(0xFFEEEEEE),
            suffixIcon: const Icon(
              Icons.calendar_today_outlined,
              color: Colors.grey,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF616161),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          items: _genders.map((String gender) {
            return DropdownMenuItem<String>(value: gender, child: Text(gender));
          }).toList(),
          onChanged: _isEditMode
              ? (newValue) => setState(() => _selectedGender = newValue)
              : null,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: _isEditMode ? Colors.white : const Color(0xFFEEEEEE),
            contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(UserEntity? currentUser) {
    const buttonStyle = TextStyle(
      fontSize: 16,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final isLoading = state is ProfileUpdateLoading;
        if (_isEditMode) {
          return Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          setState(() {
                            _isEditMode = false;
                            _photoFile = null;
                            _populateControllers(currentUser);
                          });
                        },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  child: Text(
                    'Batal',
                    style: buttonStyle.copyWith(color: Colors.grey.shade700),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () => _onSaveChanges(currentUser),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text('Simpan', style: buttonStyle),
                ),
              ),
            ],
          );
        } else {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _isEditMode = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Edit Profile', style: buttonStyle),
            ),
          );
        }
      },
    );
  }
}
