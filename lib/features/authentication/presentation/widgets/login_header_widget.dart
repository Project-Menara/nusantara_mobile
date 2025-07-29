import 'package:flutter/material.dart';
import 'package:nusantara_mobile/core/constant/color_constant.dart';
import 'package:nusantara_mobile/features/authentication/presentation/widgets/dropdown.dart';

class LoginHeaderWidget extends StatefulWidget {
  const LoginHeaderWidget({super.key});

  @override
  State<LoginHeaderWidget> createState() => _LoginHeaderWidgetState();
}

class _LoginHeaderWidgetState extends State<LoginHeaderWidget> {
  String selectedLanguage = "ID";
  final List<String> languages = ["ID"];

  // Tambahkan teks berdasarkan bahasa
  final Map<String, String> titleTexts = {
    "ID": "Oleh-oleh khas Indonesia kini lebih dekat",
    "EN": "Authentic Indonesian souvenirs are now closer to you",
  };

  final Map<String, String> subtitleTexts = {
    "ID": "Dapatkan akses promo eksklusif dan hadiah serta menu favorit Anda",
    "EN": "Get access to exclusive promotions, gifts, and your favorite menu",
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(left: 24, right: 24),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/images/logo.png', width: 100, height: 100),
                Dropdown(
                  selectedValue: selectedLanguage,
                  items: languages,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedLanguage = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              titleTexts[selectedLanguage] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ColorConstant.orange,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitleTexts[selectedLanguage] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ColorConstant.black,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
