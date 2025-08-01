import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_state.dart';

class PersonalDataPage extends StatefulWidget {
  const PersonalDataPage({super.key});

  @override
  State<PersonalDataPage> createState() => _PersonalDataPageState();
}

class _PersonalDataPageState extends State<PersonalDataPage> {
  final _fullNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  String? _selectedGender;
  final List<String> _genders = ['Laki-laki', 'Perempuan'];
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _populateControllersFromBloc();
  }

  void _populateControllersFromBloc() {
    final currentState = context.read<AuthBloc>().state;
    if (currentState is AuthLoginSuccess) {
      final user = currentState.user;
      _fullNameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
      _selectedGender = user.gender;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 120;
    const double avatarRadius = 60;

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          // Ganti ini agar memeriksa kedua state sukses
          if (state is! AuthLoginSuccess && state is! AuthGetUserSuccess) {
            return const Center(child: CircularProgressIndicator());
          }

          // Ekstrak user dari state yang sesuai
          final user = (state is AuthLoginSuccess)
              ? state.user
              : (state as AuthGetUserSuccess).user;

          return Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: headerHeight + avatarRadius),
                      // --- TAMBAHAN: Judul halaman dipindah ke sini ---
                      const Text(
                        'Personal Data',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildForm(),
                      const SizedBox(height: 30),
                      _buildActionButtons(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              _buildHeader(context, headerHeight),
              _buildProfileAvatar(headerHeight, avatarRadius, user.photo),
            ],
          );
        },
      ),
    );
  }

  Widget _buildForm() {
    return Form(
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
            readOnly: !_isEditMode,
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
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly ? Colors.grey.shade300 : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
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
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          decoration: InputDecoration(
            filled: true,
            fillColor: onTap != null ? Colors.white : Colors.grey.shade300,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: const Icon(
              Icons.calendar_today_outlined,
              color: Colors.grey,
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
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        IgnorePointer(
          ignoring: !_isEditMode,
          child: DropdownButtonFormField<String>(
            value: _selectedGender,
            items: _genders.map((String gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            onChanged: _isEditMode
                ? (newValue) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  }
                : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: _isEditMode ? Colors.white : Colors.grey.shade300,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_isEditMode) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _isEditMode = false;
                  _populateControllersFromBloc();
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
                'Cancel',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Perubahan disimpan!')),
                );
                setState(() {
                  _isEditMode = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _isEditMode = true;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildHeader(BuildContext context, double height) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      child: Container(
        height: height,
        width: double.infinity,
        color: Colors.red.shade700,
        child: SafeArea(
          child: Stack(
            children: [
              // --- PERUBAHAN: Judul dihapus dari sini ---
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ),
            ],
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: avatarRadius + 4,
            backgroundColor: Colors.grey.shade200,
            child: CircleAvatar(
              radius: avatarRadius,
              backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                  ? NetworkImage(photoUrl)
                  : const NetworkImage('https://i.pravatar.cc/150?img=56')
                        as ImageProvider,
            ),
          ),
          Positioned(
            bottom: 0,
            right: MediaQuery.of(context).size.width / 2 - avatarRadius - 18,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.orange,
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
