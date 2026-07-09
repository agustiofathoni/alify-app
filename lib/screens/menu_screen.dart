import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart'; 
import '../utils/constants.dart';
import 'drawing_screen.dart'; 
import 'learning_list_screen.dart'; 
import 'rapor_screen.dart'; 

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late AudioPlayer _bgmPlayer;
  bool _isMusicPlaying = true;

  @override
  void initState() {
    super.initState();
    _bgmPlayer = AudioPlayer();
    _startBgm();
  }

  // --- FUNGSI MEMUTAR MUSIK ---
  Future<void> _startBgm() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop); // Musik berulang
    await _bgmPlayer.setVolume(0.3); // Volume disetel 30% agar nyaman
    await _bgmPlayer.play(AssetSource('sounds/theme_song.mp3'));
  }

  // --- FUNGSI TOMBOL ON/OFF MUSIK ---
  void _toggleMusic() {
    HapticFeedback.lightImpact();
    setState(() {
      _isMusicPlaying = !_isMusicPlaying;
    });
    if (_isMusicPlaying) {
      _bgmPlayer.resume();
    } else {
      _bgmPlayer.pause();
    }
  }

  @override
  void dispose() {
    _bgmPlayer.dispose(); // Mematikan musik saat keluar dari memori
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        bottom: false,
        child: Padding(
          // Padding atas dikurangi drastis agar lebih minimalis dan padat
          padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- KONTROL ATAS: TOMBOL MUSIK & INFO SKRIPSI ---
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Tombol Musik
                  InkWell(
                    onTap: _toggleMusic,
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                      ),
                      child: Icon(
                        _isMusicPlaying ? Icons.music_note_rounded : Icons.music_off_rounded, 
                        color: _isMusicPlaying ? kPrimaryColor : Colors.grey, 
                        size: 24
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tombol Info Skripsi
                  InkWell(
                    onTap: () => _showAboutDialog(context),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                      ),
                      child: const Icon(Icons.info_outline_rounded, color: Colors.grey, size: 24),
                    ),
                  ),
                ],
              ),
              
              // --- HEADER BERANDA ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo 1: UISI
                  Container(
                    height: 50, 
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      shape: BoxShape.circle, 
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(6.0), 
                        child: Image.asset(
                          'assets/images/logo_uisi.png', 
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Logo 2: Informatika
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      shape: BoxShape.circle, 
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Image.asset(
                          'assets/images/logo_if.png', 
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Alify',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF2B2D42)),
              ),
              Text(
                'Belajar Huruf Hijaiah Sambung',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade500),
              ),
              
              const SizedBox(height: 16),
              Container(height: 3, width: 80, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),

              // --- DAFTAR MENU UTAMA ---
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 40),
                  children: [
                    // 1. MENU BELAJAR MENULIS
                    _buildMenuCard(
                      context: context,
                      title: 'Belajar Menulis',
                      subtitle: 'Pilih dan rangkai huruf Hijaiah',
                      imagePath: 'assets/images/menu_belajar.png', 
                      btnColor: Colors.blueAccent,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const LearningListScreen())); 
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 2. MENU TEBAK HURUF 
                    _buildMenuCard(
                      context: context,
                      title: 'Tebak Huruf',
                      subtitle: 'Uji kemampuan tulisan bebasmu',
                      imagePath: 'assets/images/menu_tebak.png', 
                      btnColor: kPrimaryColor, 
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const DrawingScreen(targetLetter: null)));
                      },
                    ),

                    const SizedBox(height: 24),

                    // 3. MENU RAPOR PINTAR
                    _buildMenuCard(
                      context: context,
                      title: 'Rapor Pintar',
                      subtitle: 'Lihat grafik pencapaian belajarmu!',
                      imagePath: 'assets/images/menu_rapor.png', 
                      btnColor: Colors.green,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const RaporScreen()));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- DIALOG PROFIL SKRIPSI ---
  void _showAboutDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.school_rounded, color: Colors.blue.shade400, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'TENTANG APLIKASI',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5),
              ),
              const SizedBox(height: 8),
              const Text(
                'Alify: \nAplikasi Belajar Menulis\nHuruf Hijaiah Sambung',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2B2D42), height: 1.3),
              ),
              const SizedBox(height: 24),
              Container(height: 1, color: const Color.fromARGB(255, 167, 166, 166)),
              const SizedBox(height: 24),
              const Text(
                'KARYA TUGAS AKHIR (SKRIPSI)',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ahmad Agustio Fathoni',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kPrimaryColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Program Studi Informatika\nUniversitas Internasional Semen Indonesia (UISI)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade600, height: 1.4),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    foregroundColor: Colors.grey.shade800,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET CARD KUSTOM ---
  Widget _buildMenuCard({
    required BuildContext context, 
    required String title, 
    required String subtitle, 
    required String imagePath, 
    required Color btnColor,
    required VoidCallback onTap
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: btnColor.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              image: DecorationImage(
                image: AssetImage(imagePath), 
                fit: BoxFit.cover, 
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF2B2D42)),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btnColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Mulai', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}