import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../utils/constants.dart';
import 'drawing_screen.dart'; 

class RaporScreen extends StatefulWidget {
  const RaporScreen({super.key});

  @override
  State<RaporScreen> createState() => _RaporScreenState();
}

class _RaporScreenState extends State<RaporScreen> {
  late ConfettiController _confettiController;
  
  final List<String> _hijaiahList = [
    'ا', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د', 'ذ', 'ر', 'ز', 'س', 'ش', 'ص', 'ض',
    'ط', 'ظ', 'ع', 'غ', 'ف', 'ق', 'ك', 'ل', 'م', 'ن', 'و', 'ه', 'ي'
  ];

  final Map<String, String> _kHijaiahNames = {
    'ا': 'Alif', 'ب': 'Ba', 'ت': 'Ta', 'ث': 'Tsa', 'ج': 'Jim', 'ح': 'Ha', 'خ': 'Kha',
    'د': 'Dal', 'ذ': 'Dzal', 'ر': 'Ra', 'ز': 'Zai', 'س': 'Sin', 'ش': 'Syin', 'ص': 'Shad',
    'ض': 'Dhad', 'ط': 'Tha', 'ظ': 'Zha', 'ع': 'Ain', 'غ': 'Ghain', 'ف': 'Fa', 'ق': 'Qaf',
    'ك': 'Kaf', 'ل': 'Lam', 'م': 'Mim', 'ن': 'Nun', 'و': 'Wau', 'ه': 'Ha', 'ي': 'Ya'
  };

  List<String> _masteredLetters = [];
  List<String> _needPracticeLetters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _loadProgressData();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadProgressData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> mastered = [];
    List<String> needPractice = [];

    for (String char in _hijaiahList) {
      bool isMastered = prefs.getBool('mastered_$char') ?? false;
      if (isMastered) {
        mastered.add(char);
      } else {
        needPractice.add(char);
      }
    }

    double progressPercent = _hijaiahList.isEmpty ? 0 : (mastered.length / _hijaiahList.length);

    setState(() {
      _masteredLetters = mastered;
      _needPracticeLetters = needPractice;
      _isLoading = false;
    });

    if (progressPercent >= 0.8) {
      _confettiController.play();
    }
  }

  Future<void> _resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    for (String char in _hijaiahList) {
      await prefs.remove('mastered_$char');
    }
    
    setState(() {
      _isLoading = true;
    });
    await _loadProgressData();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Progres berhasil direset ke 0!'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalLetters = _hijaiahList.length;
    int masteredCount = _masteredLetters.length;
    double progressPercent = totalLetters == 0 ? 0 : (masteredCount / totalLetters);

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
          'Rapor Pintar',
          style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2B2D42), fontSize: 22),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: kRedColor),
            tooltip: 'Reset Progres',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text('Reset Progres?'),
                  content: const Text('Semua bintang emas akan hilang dan progres kembali dari awal. Yakin?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _resetProgress();
                      },
                      child: const Text('Reset', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.shade200, width: 2),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text('Total Penguasaan Huruf', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 16),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: CircularProgressIndicator(
                                    value: progressPercent,
                                    strokeWidth: 12,
                                    backgroundColor: Colors.grey.shade100,
                                    color: kPrimaryColor,
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                                Text(
                                  '${(progressPercent * 100).toInt()}%',
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: kPrimaryColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '$masteredCount dari $totalLetters Huruf Dikuasai',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF2B2D42)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      Row(
                        children: [
                          const Icon(Icons.verified_rounded, color: Colors.green),
                          const SizedBox(width: 8),
                          Text('Sangat Dikuasai (${_masteredLetters.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2B2D42))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_masteredLetters.isEmpty)
                        _buildEmptyState('Belum ada huruf yang dikuasai.\nAyo latihan lebih banyak lagi!', Colors.green.shade50)
                      else
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: _masteredLetters.length,
                            itemBuilder: (context, index) {
                              return _buildLetterChip(context, _masteredLetters[index], true);
                            },
                          ),
                        ),
                      
                      const SizedBox(height: 32),

                      Row(
                        children: [
                          const Icon(Icons.trending_up_rounded, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text('Perlu Latihan (${_needPracticeLetters.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2B2D42))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_needPracticeLetters.isEmpty)
                        _buildEmptyState('Hebat! Kamu sudah menguasai semua huruf.', Colors.orange.shade50)
                      else
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: _needPracticeLetters.length,
                            itemBuilder: (context, index) {
                              return _buildLetterChip(context, _needPracticeLetters[index], false);
                            },
                          ),
                        ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
          
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, 
              maxBlastForce: 5, 
              minBlastForce: 2, 
              emissionFrequency: 0.05,
              numberOfParticles: 40,
              gravity: 0.15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, Color bgColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700, height: 1.5),
      ),
    );
  }

  Widget _buildLetterChip(BuildContext context, String char, bool isMastered) {
  String name = _kHijaiahNames[char] ?? '';
  
  // Daftar huruf yang punya lengkungan ke bawah
  // bool hasDescender = ['ج', 'ح', 'خ', 'ع', 'غ', 'م'].contains(char);

  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DrawingScreen(
              targetLetter: char,
              customLetterList: isMastered ? _masteredLetters : _needPracticeLetters,
            ),
          ),
        ).then((_) {
          setState(() { _isLoading = true; });
          _loadProgressData();
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: isMastered ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isMastered ? Colors.green.shade200 : Colors.grey.shade300, width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Padding atas tambahan jika ada lengkungan bawah
          SizedBox(
            height: 60, 
            child: Center(
              child: Text(
                char,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  color: isMastered ? Colors.green.shade700 : const Color(0xFF2B2D42),
                  height: 1.0,
                ),
              ),
            ),
          ),
            const SizedBox(height: 4),
    
          // 3. NAMA HURUF
          Text(
            name,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isMastered ? Colors.green.shade700 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
      ),
    ),
  );
}
}