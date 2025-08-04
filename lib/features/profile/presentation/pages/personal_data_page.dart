import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nusantara_mobile/core/helper/flashbar_helper.dart';
import 'package:nusantara_mobile/core/injection_container.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_event.dart'
    as auth_event;
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:nusantara_mobile/features/profile/presentation/bloc/profile_bloc.dart';

class PersonalDataPage extends StatelessWidget {
  const PersonalDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProfileBloc>(),
      child: const PersonalDataView(),
    );
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

  UserEntity? get currentUser {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) return authState.user;
    if (authState is AuthGetUserSuccess) return authState.user;
    if (authState is AuthUpdateSuccess) return authState.user;
    return null;
  }

  @override
  void initState() {
    super.initState();
    _populateControllers(currentUser);
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
    if (user != null) {
      _fullNameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
      _selectedGender = (user.gender == 'Male' || user.gender == 'Laki-laki')
          ? 'Laki-laki'
          : 'Perempuan';
      if (user.dateOfBirth != null) {
        _dobController.text =
            DateFormat('dd/MM/yyyy').format(user.dateOfBirth!);
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

  void _onSaveChanges() {
    if (currentUser == null) return;

    DateTime? newDob;
    if (_dobController.text.isNotEmpty) {
      try {
        newDob = DateFormat('dd/MM/yyyy').parse(_dobController.text);
      } catch (e) {
        showAppFlashbar(context,
            title: "Format Tanggal Salah",
            message: "Silakan periksa kembali tanggal lahir Anda.",
            isSuccess: false);
        return;
      }
    }

    final updatedData = currentUser!.copyWith(
      name: _fullNameController.text,
      gender: _selectedGender,
      dateOfBirth: newDob,
    );

    context.read<ProfileBloc>().add(
          UpdateProfileButtonPressed(user: updatedData, photoFile: _photoFile),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: Colors.red.shade700,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: const Text('Profile Settings',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileUpdateSuccess) {
                // <<< PERBAIKAN 1: Hapus `Navigator.pop()` karena dialog tidak ada lagi >>>
                context
                    .read<AuthBloc>()
                    .add(auth_event.AuthUserUpdated(state.updatedUser));
                showAppFlashbar(context,
                    title: "Sukses",
                    message: "Profil berhasil diperbarui.",
                    isSuccess: true);
                setState(() {
                  _isEditMode = false;
                  _photoFile = null;
                });
              } else if (state is ProfileUpdateFailure) {
                // <<< PERBAIKAN 2: Hapus `Navigator.pop()` >>>
                showAppFlashbar(context,
                    title: "Gagal",
                    message: state.message,
                    isSuccess: false);
              } 
              // <<< PERBAIKAN 3: Hapus seluruh blok `else if (state is ProfileUpdateLoading)` >>>
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
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! AuthLoginSuccess &&
                authState is! AuthGetUserSuccess &&
                authState is! AuthUpdateSuccess) {
              return const Center(child: CircularProgressIndicator());
            }
            final UserEntity user;
            if (authState is AuthLoginSuccess) {
              user = authState.user;
            } else if (authState is AuthGetUserSuccess) {
              user = authState.user;
            } else {
              user = (authState as AuthUpdateSuccess).user;
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 120.0),
              child: Column(
                children: [
                  _buildProfileAvatar(user.photo),
                  const SizedBox(height: 32),
                  _buildForm(),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
            24, 8, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: _buildActionButtons(),
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
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10)
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
          style: const TextStyle(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly ? const Color(0xFFEEEEEE) : Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              borderSide: const BorderSide(color: Colors.orange, width: 1.5),
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
            suffixIcon:
                const Icon(Icons.calendar_today_outlined, color: Colors.grey),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              fontSize: 14),
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
              fontWeight: FontWeight.w500, color: Colors.black, fontSize: 16),
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

  Widget _buildActionButtons() {
    const buttonStyle =
        TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold);
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
                          borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.grey.shade400)),
                  child: Text('Batal',
                      style: buttonStyle.copyWith(color: Colors.grey.shade700)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : _onSaveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 3))
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
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Edit Profile', style: buttonStyle),
            ),
          );
        }
      },
    );
  }

  Widget _buildProfileAvatar(String? photoUrl) {
    const double avatarRadius = 50;
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: avatarRadius + 4,
            backgroundColor: const Color(0xFFF5F5F5),
            child: CircleAvatar(
              radius: avatarRadius,
              backgroundImage: (_photoFile != null
                  ? FileImage(_photoFile!)
                  : (photoUrl != null && photoUrl.isNotEmpty)
                      ? NetworkImage(photoUrl)
                      : const NetworkImage(
                          'https://i.pravatar.cc/150?img=56')) as ImageProvider,
            ),
          ),
          if (_isEditMode)
            Positioned(
              bottom: 0,
              right: 0,
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.orange,
                  child:
                      Icon(Icons.camera_alt, size: 16, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}