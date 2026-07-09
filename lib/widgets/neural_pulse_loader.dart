import 'package:flutter/material.dart';
import 'dart:math' as math;

class KidsAnalyzerLoader extends StatefulWidget {
  final String message;
  const KidsAnalyzerLoader({super.key, this.message = "Sedang melihat tulisanmu..."});

  @override
  State<KidsAnalyzerLoader> createState() => _KidsAnalyzerLoaderState();
}

class _KidsAnalyzerLoaderState extends State<KidsAnalyzerLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    // Durasi animasi bergoyang
    _controller = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 500)
    );
    
    // Animasi membesar dan mengecil (efek nafas/bouncing)
    _bounceAnimation = Tween<double>(begin: 0.9, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    // Animasi miring kiri-kanan (efek mencari/wobble)
    _rotateAnimation = Tween<double>(begin: -0.15, end: 0.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Bikin animasinya bolak-balik tanpa henti
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Latar belakang putih transparan agar kanvas masih mengintip
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35), // Sudut sangat membulat khas UI anak-anak
            border: Border.all(color: Colors.orange.shade300, width: 4), // Border tebal seperti kartun
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 8,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _bounceAnimation.value,
                    child: Transform.rotate(
                      angle: _rotateAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: const Icon(
                  Icons.search_rounded, // Ikon kaca pembesar
                  color: Color(0xFFE89A3D),
                  size: 65,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2B2D42),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Tunggu sebentar ya! ✨",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}