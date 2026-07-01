import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import 'menu_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor, // Warna latar ceria/pastel
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // --- HEADER LOGO ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Placeholder Logo UISI (Bisa diganti Image.asset)
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0), // Jarak aman ke tepi lingkaran
                        child: Image.asset(
                          'assets/images/logo_uisi.png', // Ganti dengan nama file logo pertama Anda
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Logo 2: Logo IF
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/logo_if.png', // Ganti dengan nama file logo kedua Anda
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // --- SALAM ---
              const Text(
                'Assalamualaikum',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2B2D42),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mari seru-seruan belajar menulis huruf hijaiah sambung!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 40),

             // --- ILUSTRASI UTAMA ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: kPrimaryColor.withOpacity(0.2), width: 4),
                    boxShadow: [
                      BoxShadow(color: kPrimaryColor.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))
                    ],
                  ),
                  // Gunakan ClipRRect agar ujung gambar ikut melengkung menempel border
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28), // Ukuran harus sedikit lebih kecil dari border luar
                    child: Image.asset(
                      'assets/images/icon_awal.png', 
                      fit: BoxFit.cover, // Cover memaksa gambar memenuhi seluruh celah
                      width: double.infinity,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              const SizedBox(height: 40),

              // --- TOMBOL MULAI BELAJAR ---
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const MenuScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shadowColor: kPrimaryColor.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Mulai Belajar ✨',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}