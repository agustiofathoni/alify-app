import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import 'drawing_screen.dart';

class LearningListScreen extends StatelessWidget {
  const LearningListScreen({super.key});

  final List<String> _hijaiahList = const [
    'ا', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د', 'ذ', 'ر', 'ز', 'س', 'ش', 'ص', 'ض',
    'ط', 'ظ', 'ع', 'غ', 'ف', 'ق', 'ك', 'ل', 'م', 'ن', 'و', 'ه', 'ي'
  ];

  // Tambahan: Map untuk nama huruf
  final Map<String, String> _kHijaiahNames = const {
    'ا': 'Alif', 'ب': 'Ba', 'ت': 'Ta', 'ث': 'Tsa', 'ج': 'Jim', 'ح': 'Ha', 'خ': 'Kha',
    'د': 'Dal', 'ذ': 'Dzal', 'ر': 'Ra', 'ز': 'Zai', 'س': 'Sin', 'ش': 'Syin', 'ص': 'Shad',
    'ض': 'Dhad', 'ط': 'Tha', 'ظ': 'Zha', 'ع': 'Ain', 'غ': 'Ghain', 'ف': 'Fa', 'ق': 'Qaf',
    'ك': 'Kaf', 'ل': 'Lam', 'م': 'Mim', 'ن': 'Nun', 'و': 'Wau', 'ه': 'Ha', 'ي': 'Ya'
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        toolbarHeight: 70,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: kSecondaryColor.withOpacity(0.2), blurRadius: 5)]),
              child: const Icon(Icons.arrow_back_rounded, color: kRedColor, size: 28),
            ),
          ),
        ),
        title: const Text(
          'Pilih Huruf',
          style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2B2D42), fontSize: 22),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl, 
        child: GridView.builder(
          padding: const EdgeInsets.all(24.0),
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, 
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85, // Diubah menjadi 0.85 agar kotaknya sedikit lebih tinggi (cukup untuk 2 baris teks)
          ),
          itemCount: _hijaiahList.length,
          // Ganti bagian itemBuilder ini dengan kode berikut:
          itemBuilder: (context, index) {
            String char = _hijaiahList[index];
            String name = _kHijaiahNames[char] ?? '';

            // Daftar huruf yang punya lengkungan ke bawah
            // bool hasDescender = ['ج', 'ح', 'خ', 'ع', 'غ', 'م'].contains(char);

            return InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DrawingScreen(targetLetter: char, customLetterList: _hijaiahList),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.teal.shade200, width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 3))
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Pusatkan secara vertikal
                  children: [
                    // 1. WADAH TETAP (Tinggi 60px) agar semua huruf sejajar
                    SizedBox(
                      height: 60, 
                      child: Center(
                        child: Text(
                          char,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                    
                    // 2. Jarak kecil
                    const SizedBox(height: 4),
                    
                    // 3. Nama Huruf
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.orange.shade300,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}