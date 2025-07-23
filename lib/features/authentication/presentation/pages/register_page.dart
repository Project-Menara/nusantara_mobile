import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  final String phoneNumber;

  // Menerima nomor telepon dari halaman login
  const RegisterScreen({super.key, required this.phoneNumber});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller untuk setiap field
  late final TextEditingController _phoneController;
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();

  // State untuk dropdown dan checkbox
  String? _selectedGender;
  bool _agreeToTerms = false;
  
  static const Color primaryOrange = Color(0xFFF57C00);

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller telepon dengan nomor yang diterima
    _phoneController = TextEditingController(text: widget.phoneNumber);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // AppBar transparan agar menyatu dengan body
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Logo
              Image.asset(
                'assets/images/logo.png', // Pastikan path logo benar
                height: 50,
              ),
              const SizedBox(height: 24),

              // 2. Judul
              const Text(
                'Create Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),

              // 3. Form Fields
              _buildTextField(
                label: 'Full Name',
                hint: 'Enter your Full Name',
                controller: _fullNameController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Email',
                hint: 'Enter your Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Phone Number',
                hint: 'Enter your Phone Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                readOnly: true, // Tidak bisa diubah
              ),
              const SizedBox(height: 16),

              // 4. Dropdown Gender
              _buildGenderDropdown(),
              const SizedBox(height: 24),

              // 5. Checkbox Syarat & Ketentuan
              _buildTermsAndConditions(),
              const SizedBox(height: 32),

              // 6. Tombol Create Account
              ElevatedButton(
                onPressed: () {
                  // TODO: Tambahkan logika untuk membuat akun
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper widget untuk membangun TextFormField agar tidak berulang
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryOrange, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
  
  /// Widget untuk Dropdown Pilihan Gender
  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          hint: Text('Choose your Gender', style: TextStyle(color: Colors.grey.shade400)),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          items: ['Male', 'Female']
              .map((gender) => DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
        ),
      ],
    );
  }

  /// Widget untuk Checkbox dan teks Syarat & Ketentuan
  Widget _buildTermsAndConditions() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: (value) {
              setState(() {
                _agreeToTerms = value ?? false;
              });
            },
            activeColor: primaryOrange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
              children: [
                const TextSpan(text: 'Saya setuju dengan '),
                TextSpan(
                  text: 'Syarat & Ketentuan',
                  style: const TextStyle(color: primaryOrange, decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // TODO: Buka halaman Syarat & Ketentuan
                      print('Navigate to Terms & Conditions');
                    },
                ),
                const TextSpan(text: ' dan '),
                TextSpan(
                  text: 'Kebijakan Privasi',
                  style: const TextStyle(color: primaryOrange, decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // TODO: Buka halaman Kebijakan Privasi
                      print('Navigate to Privacy Policy');
                    },
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}