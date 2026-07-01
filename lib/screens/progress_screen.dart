import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'drawing_screen.dart';
import '../utils/constants.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  Map<String, bool> _masteredLetters = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, bool> tempMap = {};
    for (String letter in kHijaiahLabels) {
      tempMap[letter] = prefs.getBool('mastered_$letter') ?? false;
    }
    setState(() => _masteredLetters = tempMap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        title: const Text('Rapor Hijaiah', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2B2D42))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2B2D42)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GridView.builder(
          itemCount: kHijaiahLabels.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, 
            crossAxisSpacing: 16, 
            mainAxisSpacing: 16
          ),
          itemBuilder: (context, index) {
            String letter = kHijaiahLabels[index];
            bool isMastered = _masteredLetters[letter] ?? false;

            return GestureDetector(
              onTap: () {
                // Jika ditekan, langsung masuk ke mode Tracing untuk huruf tersebut
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => DrawingScreen(targetLetter: letter))
                ).then((_) => _loadProgress()); // Muat ulang progres saat kembali
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isMastered ? Colors.white : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isMastered ? kSecondaryColor : Colors.transparent, width: 3),
                  boxShadow: isMastered ? [BoxShadow(color: kSecondaryColor.withOpacity(0.3), blurRadius: 8)] : [],
                ),
                child: Center(
                  child: isMastered 
                      ? Text(letter, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: kPrimaryColor))
                      : const Icon(Icons.lock_rounded, color: Colors.grey, size: 28),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}