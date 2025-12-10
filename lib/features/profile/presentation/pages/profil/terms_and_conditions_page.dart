import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(top: 18.0, bottom: 8.0),
    child: Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    ),
  );

  Widget _paragraph(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: Text(
      text,
      style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
    ),
  );

  @override
  Widget build(BuildContext context) {
    const lorem1 =
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin '
        'vel ligula eu erat facilisis tincidunt. Sed at urna at dui rhoncus '
        'placerat. Integer vitae lectus vitae arcu vehicula pharetra. Integer '
        'euismod, nisl eget convallis pellentesque, arcu sapien viverra nibh, '
        'vitae elementum nunc odio a metus.';

    const lorem2 =
        'Vestibulum ante ipsum primis in faucibus orci luctus et '
        'ultrices posuere cubilia curae; Aenean non dui ac mauris tincidunt '
        'varius. Cras vulputate, purus in volutpat hendrerit, justo orci '
        'volutpat sapien, eu tristique urna magna ac justo.';

    const lorem3 =
        'Suspendisse potenti. Nulla facilisi. Vivamus non sem '
        'nec lacus dapibus tincidunt. Sed id libero sed arcu ultrices '
        'sollicitudin. In hac habitasse platea dictumst. Integer ac nibh eget '
        'urna efficitur gravida.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Selamat datang di Nusantara — silakan baca syarat dan ketentuan berikut sebelum menggunakan layanan kami.',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),

                    _sectionTitle('1. Ketentuan Umum'),
                    _paragraph(lorem1),

                    _sectionTitle('2. Ruang Lingkup Layanan'),
                    _paragraph(lorem2),

                    _sectionTitle('3. Hak dan Kewajiban Pengguna'),
                    _paragraph(lorem3),

                    _sectionTitle('4. Pembayaran dan Biaya'),
                    _paragraph(lorem1),

                    _sectionTitle('5. Privasi & Data'),
                    _paragraph(
                      'Kami menghargai privasi Anda. Informasi yang dikumpulkan akan diproses sesuai kebijakan privasi kami.',
                    ),

                    _sectionTitle('6. Batasan Tanggung Jawab'),
                    _paragraph(
                      'Nusantara tidak bertanggung jawab atas kerugian tidak langsung, kehilangan keuntungan, atau kerusakan yang timbul akibat penggunaan layanan ini.',
                    ),

                    _sectionTitle('7. Perubahan Ketentuan'),
                    _paragraph(
                      'Kami berhak mengubah syarat dan ketentuan ini sewaktu-waktu. Perubahan akan diumumkan melalui aplikasi.',
                    ),

                    _sectionTitle('8. Hukum yang Berlaku'),
                    _paragraph(
                      'Syarat dan ketentuan ini diatur oleh hukum yang berlaku di Republik Indonesia.',
                    ),

                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Terima kasih telah membaca. Dengan melanjutkan menggunakan aplikasi Nusantara, Anda menyetujui syarat dan ketentuan ini.',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Tutup',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
