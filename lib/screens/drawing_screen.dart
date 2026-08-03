import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:signature/signature.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/tflite_service.dart';
import '../utils/constants.dart';
import '../widgets/neural_pulse_loader.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

double getOffsetForChar(String char) {
  if (['ج', 'ح', 'خ', 'ع', 'غ', 'م', 'ن', 'ي', 'ق', 'ش', 'س', 'ص', 'ض'].contains(char)) {
    return -25.0; 
  }
  return 0.0; 
}

final Map<String, String> kHijaiahNames = {
  'ا': 'Alif', 'ب': 'Ba', 'ت': 'Ta', 'ث': 'Tsa', 'ج': 'Jim', 'ح': 'Ha', 'خ': 'Kha',
  'د': 'Dal', 'ذ': 'Dzal', 'ر': 'Ra', 'ز': 'Zai', 'س': 'Sin', 'ش': 'Syin', 'ص': 'Shad',
  'ض': 'Dhad', 'ط': 'Tha', 'ظ': 'Zha', 'ع': 'Ain', 'غ': 'Ghain', 'ف': 'Fa', 'ق': 'Qaf',
  'ك': 'Kaf', 'ل': 'Lam', 'م': 'Mim', 'ن': 'Nun', 'و': 'Wau', 'ه': 'Hha', 'ي': 'Ya'
};

class LayoutControl {
  final double scale;
  final double offsetY;
  const LayoutControl({this.scale = 1.0, this.offsetY = 0.0});
}

final Map<String, LayoutControl> kLayoutControls = {
  'ا': const LayoutControl(scale: 1.3, offsetY: 40),    
  'ب': const LayoutControl(scale: 1.2, offsetY: 40),    
  'ت': const LayoutControl(scale: 1.2, offsetY: 30),    
  'ث': const LayoutControl(scale: 1.2, offsetY: 30),    
  'ج': const LayoutControl(scale: 1.2, offsetY: 40),    
  'ح': const LayoutControl(scale: 1.2, offsetY: 40),
  'خ': const LayoutControl(scale: 1.2, offsetY: 40),
  'د': const LayoutControl(scale: 1.2, offsetY: 40),
  'ذ': const LayoutControl(scale: 1.2, offsetY: 40),
  'ر': const LayoutControl(scale: 1.2, offsetY: 60),
  'ز': const LayoutControl(scale: 1.2, offsetY: 40),
  'س': const LayoutControl(scale: 1.2, offsetY: 40),
  'ش': const LayoutControl(scale: 1.2, offsetY: 40),
  'ص': const LayoutControl(scale: 1.2, offsetY: 40),
  'ض': const LayoutControl(scale: 1.15, offsetY: 40),
  'ط': const LayoutControl(scale: 1.2, offsetY: 40),
  'ظ': const LayoutControl(scale: 1.25, offsetY: 40),
  'ع': const LayoutControl(scale: 1.2, offsetY: 30),
  'غ': const LayoutControl(scale: 1.25, offsetY: 30),
  'ف': const LayoutControl(scale: 1.2, offsetY: 40),
  'ق': const LayoutControl(scale: 1.3, offsetY: 40),
  'ك': const LayoutControl(scale: 1.2, offsetY: 30),
  'ل': const LayoutControl(scale: 1.3, offsetY: 30),
  'م': const LayoutControl(scale: 1.3, offsetY: 30),
  'ن': const LayoutControl(scale: 1.3, offsetY: 40),
  'و': const LayoutControl(scale: 1.2, offsetY: 50),
  'ه': const LayoutControl(scale: 1.2, offsetY: 40),
  'ي': const LayoutControl(scale: 1.3, offsetY: 50),
  };

class LetterGuide {
  final String awalan;
  final String tengah;
  final String akhiran;
  final String rule;
  const LetterGuide(this.awalan, this.tengah, this.akhiran, this.rule);
}

final Map<String, LetterGuide> kLetterGuides = {
  'ا': const LetterGuide('ا', 'ـا', 'ـاب', 'Alif adalah huruf "Pemalu". Dia mau bergandengan dengan teman di sebelah kanan, tapi tidak mau bergandengan dengan teman di sebelah kirinya.'),
  'د': const LetterGuide('د', 'ـد', 'ـدب', 'Dal adalah huruf "Pemalu". Dia mau bergandengan dengan teman di sebelah kanan, tapi tidak mau bergandengan dengan teman di sebelah kirinya.'),
  'ذ': const LetterGuide('ذ', 'ـذ', 'ـذب', 'Dzal juga huruf "Pemalu". Dia mau bergandengan dengan teman di sebelah kanan, tapi tidak mau bergandengan dengan teman di sebelah kirinya.'),
  'ر': const LetterGuide('ر', 'ـر', 'ـرب', 'Ra adalah huruf "Pemalu". Dia mau bergandengan dengan teman di sebelah kanan, tapi tidak mau bergandengan dengan teman di sebelah kirinya.'),
  'ز': const LetterGuide('ز', 'ـز', 'ـزب', 'Zai adalah huruf "Pemalu". Dua mau bergandengan dengan teman di sebelah kanan, tapi tidak mau bergandengan dengan teman di sebelah kirinya.'),
  'و': const LetterGuide('و', 'ـو', 'ـوب', 'Wau adalah huruf "Pemalu". Dia mau bergandengan dengan teman di sebelah kanan, tapi tidak mau bergandengan dengan teman di sebelah kirinya.'),
  'ب': const LetterGuide('بـ', 'ـبـ', 'ـب', 'Ba adalah huruf "Ramah". Dia bisa bersambung dengan huruf di kanan maupun di kirinya.'),
  'ت': const LetterGuide('تـ', 'ـتـ', 'ـت', 'Ta adalah huruf "Ramah" yang bisa bersambung ke dua sisi.'),
  'ث': const LetterGuide('ثـ', 'ـثـ', 'ـث', 'Tsa juga huruf "Ramah" yang siap bersambung ke dua sisi.'),
  'ج': const LetterGuide('جـ', 'ـجـ', 'ـج', 'Jim melepas lengkungan perut besarnya saat berada di awal dan di tengah agar bisa bersambung.'),
  'ح': const LetterGuide('حـ', 'ـحـ', 'ـح', 'Ha adalah huruf "Ramah" yang melepas perut besarnya saat di awal dan di tengah kata.'),
  'خ': const LetterGuide('خـ', 'ـخـ', 'ـخ', 'Kha juga huruf "Ramah" yang melepas lengkungan perutnya saat di awal dan tengah.'),
  'س': const LetterGuide('سـ', 'ـسـ', 'ـس', 'Sin adalah huruf "Ramah". Ekor melengkungnya dihilangkan saat berada di awal dan tengah kata.'),
  'ش': const LetterGuide('شـ', 'ـشـ', 'ـش', 'Syin adalah huruf "Ramah". Ekornya dipotong agar bisa menyambung dengan huruf lain.'),
  'ص': const LetterGuide('صـ', 'ـصـ', 'ـص', 'Shad melepaskan ekor besarnya agar bisa bersambung di awal dan tengah kata.'),
  'ض': const LetterGuide('ضـ', 'ـضـ', 'ـض', 'Dhad juga huruf "Ramah" yang melepaskan ekornya di awal dan tengah.'),
  'ط': const LetterGuide('طـ', 'ـطـ', 'ـط', 'Tha adalah huruf "Ramah" yang bentuknya tetap stabil di semua posisi.'),
  'ظ': const LetterGuide('ظـ', 'ـظـ', 'ـظ', 'Zha juga sangat "Ramah" dan bentuk utamanya tidak banyak berubah saat disambung.'),
  'ع': const LetterGuide('عـ', 'ـعـ', 'ـع', 'Ain unik! Di tengah dan akhir kata, kepalanya tertutup menjadi seperti segitiga.'),
  'غ': const LetterGuide('غـ', 'ـغـ', 'ـغ', 'Sama seperti Ain, kepala Ghain akan tertutup penuh saat berada di tengah dan akhir kata.'),
  'ف': const LetterGuide('فـ', 'ـفـ', 'ـف', 'Fa adalah huruf "Ramah". Kepalanya terbuka dan siap bersambung di posisi mana pun.'),
  'ق': const LetterGuide('قـ', 'ـقـ', 'ـق', 'Qaf melepas perut melengkungnya di awal dan tengah, tapi kembali utuh saat di akhir kata.'),
  'ك': const LetterGuide('كـ', 'ـكـ', 'ـك', 'Kaf berubah bentuk: di awal/tengah dia meregang panjang, di akhir dia kembali seperti semula.'),
  'ل': const LetterGuide('لـ', 'ـلـ', 'ـل', 'Lam adalah huruf "Ramah". Dia sangat suka disambung ke kiri!'),
  'م': const LetterGuide('مـ', 'ـمـ', 'ـم', 'Mim adalah huruf "Ramah". Bulatan kepalanya akan sedikit menunduk ke bawah saat di tengah dan akhir.'),
  'ن': const LetterGuide('نـ', 'ـنـ', 'ـن', 'Nun melepas mangkuknya di awal dan tengah kata, menjadikannya mirip huruf Ba.'),
  'ه': const LetterGuide('هـ', 'ـهـ', 'ـه', 'Ha sangat ajaib! Bentuknya berubah di awal, tengah (seperti pita), dan akhir kata.'),
  'ي': const LetterGuide('يـ', 'ـيـ', 'ـي', 'Ya melepaskan ekornya di awal dan tengah kata menjadi mirip huruf Ba.'),
};

class WatermarkConfig {
  final String imagePath;     
  final double scale;     
  final double offsetY;   

  const WatermarkConfig({
    required this.imagePath,
    this.scale = 1.0,
    this.offsetY = 0.0,
  });
}

class DrawingScreen extends StatefulWidget {
  final String? targetLetter; 
  final List<String>? customLetterList;
  
  const DrawingScreen({super.key, this.targetLetter, this.customLetterList});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 12, 
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent, 
  );

  final List<String> _hijaiahList = [
    'ا', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د', 'ذ', 'ر', 'ز', 'س', 'ش', 'ص', 'ض',
    'ط', 'ظ', 'ع', 'غ', 'ف', 'ق', 'ك', 'ل', 'م', 'ن', 'و', 'ه', 'ي'
  ];
  
  late String _currentLetter; 
  late List<String> _activeList; 
  final TFLiteService _tfliteService = TFLiteService();
  final GlobalKey _canvasKey = GlobalKey(); 
  
  bool _isLoading = false;
  bool _hideWatermark = false; 

  @override
  void initState() {
    super.initState();
    _activeList = (widget.customLetterList != null && widget.customLetterList!.isNotEmpty) 
        ? widget.customLetterList! 
        : _hijaiahList;
    _currentLetter = widget.targetLetter ?? _activeList.first; 
    _initModel();
  }

  Future<void> _initModel() async {
    try {
      await _tfliteService.initialize();
    } catch (e) {
      debugPrint("Gagal inisialisasi model: $e");
    }
  }

  void _prevLetter() {
    HapticFeedback.lightImpact(); 
    int currentIndex = _activeList.indexOf(_currentLetter);
    int prevIndex = (currentIndex - 1 + _activeList.length) % _activeList.length; 
    setState(() { _currentLetter = _activeList[prevIndex]; _controller.clear(); });
  }

  void _nextLetter() {
    HapticFeedback.lightImpact(); 
    int currentIndex = _activeList.indexOf(_currentLetter);
    int nextIndex = (currentIndex + 1) % _activeList.length; 
    setState(() { _currentLetter = _activeList[nextIndex]; _controller.clear(); });
  }

  void _showLetterGuideSheet() {
    final guide = kLetterGuides[_currentLetter]; 
    final letterName = kHijaiahNames[_currentLetter] ?? '';

    // Daftar huruf nonsambung (pemalu/egois)
    final List<String> hurufNonsambung = ['ا', 'د', 'ذ', 'ر', 'ز', 'و'];
    
    // Cek apakah huruf saat ini termasuk dalam daftar huruf nonsambung
    final bool isNonsambung = hurufNonsambung.contains(_currentLetter);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text('Panduan Huruf $letterName', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kPrimaryColor)),
              const SizedBox(height: 24),
              if (guide == null)
                const Text('Panduan untuk huruf ini sedang disiapkan!', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
              else ...[
                // Kotak Aturan Utama
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blue.shade100)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(child: Text(guide.rule, style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.w600, height: 1.4))),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Ilustrasi Awalan, Tengah, Akhiran
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFormCard('Akhiran', guide.akhiran),
                    _buildFormCard('Tengah', guide.tengah),
                    _buildFormCard('Awalan', guide.awalan),
                  ],
                ),
                
                // ==========================================
                // DISCLAIMER HANYA UNTUK HURUF NONSAMBUNG
                // ==========================================
                if (isNonsambung) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline_rounded, color: Colors.orange.shade800, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Disclaimer: Huruf Ba (ب) pada contoh di atas digunakan sebagai huruf perantara standar. Tujuannya untuk memperjelas bentuk huruf $letterName yang menolak disambung ke kiri.',
                            style: TextStyle(color: Colors.orange.shade900, fontSize: 13, fontWeight: FontWeight.w500, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // ==========================================
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: () { HapticFeedback.lightImpact(); Navigator.pop(context); },
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('Paham!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildFormCard(String title, String letterForm) {
    return Column(
      children: [
        Container(
          width: 70, height: 70,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]),
          child: Center(
            child: Text(letterForm, style: const TextStyle(fontFamily: 'Amiri', fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF2B2D42))),
          ),
        ),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600, fontSize: 13)),
      ],
    );
  }

  // UNTUK ANDROID (GETARAN SAAT TERDETEKSI SALAH)
  void _showWarningDialog(String title, String message, IconData icon, Color color) async {
  // Mengecek apakah perangkat keras memiliki motor getar, lalu paksa getar 200 ms
  bool? hasVibrator = await Vibration.hasVibrator();
  if (hasVibrator == true) {
    Vibration.vibrate(duration: 500, amplitude: 128); 
  } 

  // // UNTUK iOS (GETARAN SAAT TERDETEKSI SALAH)
  // void _showWarningDialog(String title, String message, IconData icon, Color color) {
  //   // Menggunakan HapticFeedback bawaan Flutter untuk getaran kuat
  //   HapticFeedback.vibrate(); 


    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 70, color: color),
              const SizedBox(height: 16),
              Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    setState(() => _controller.clear()); 
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('Tulis Ulang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _classify() async {
    if (_controller.isEmpty) {
      // Hapus antrean SnackBar sebelumnya agar tidak menumpuk (spam)
      ScaffoldMessenger.of(context).clearSnackBars();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kanvas masih kosong! Yuk, tulis huruf hijaiahmu dulu di sini. ✨'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_controller.points.length < 40) { 
      // Hapus antrean SnackBar sebelumnya agar tidak menumpuk (spam)
      ScaffoldMessenger.of(context).clearSnackBars();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Goresan terlalu pendek. Yuk, tulis yang jelas!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2)
        ),
      );
      return;
    }
    
    setState(() { _isLoading = true; _hideWatermark = true; });
    HapticFeedback.mediumImpact(); 
    await Future.delayed(const Duration(milliseconds: 100)); 

    RenderRepaintBoundary boundary = _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    try {
      if (byteData != null) {
        final Uint8List bytes = byteData.buffer.asUint8List();
        final rawResult = await _tfliteService.classifyImage(bytes);
        
        setState(() { _isLoading = false; _hideWatermark = false; });

        if (!mounted) return;

        if (rawResult == "Model belum siap!" || !rawResult.contains('|')) {
          _showWarningDialog('Oops, Error!', 'Sistem mengalami gangguan saat membaca gambar.', Icons.error_outline, Colors.redAccent);
          return; 
        }
        
        var splitResults = rawResult.split('|');
        var parts = splitResults[0].split(' ('); 
        String char = parts[0].trim();
        double conf = double.tryParse(parts[1].replaceAll('%)', '')) ?? 0.0;
        
        if (conf < 50) {
          _showWarningDialog(
            'Kurang Yakin 🤔', 
            'Sistem agak kesulitan membaca tulisanmu (Akurasi: ${conf.toStringAsFixed(0)}%).\nYuk, coba tulis lebih rapi lagi!', 
            Icons.question_mark_rounded, 
            Colors.orange
          );
          return;
        }

        if (widget.targetLetter != null) {
          String cleanChar = char.trim();
          String cleanTarget = _currentLetter.trim();

          if (cleanChar != cleanTarget) {
            String letterName = kHijaiahNames[cleanChar] ?? '';
            _showWarningDialog(
              'Oops, Kurang Tepat!', 
              'Itu sepertinya huruf $letterName ($cleanChar).\nAyo coba ikuti panduan dan tulis huruf $_currentLetter!', 
              Icons.edit_off_rounded, 
              kRedColor
            );
            return;
          }
        }
        
        int starsEarned = conf >= 90 ? 3 : (conf >= 60 ? 2 : 1);
        if (starsEarned == 3) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('mastered_$char', true);
        } else {
          HapticFeedback.lightImpact();
        }

        _showResultDialog(char, conf, starsEarned, splitResults);
      }
    } catch (e) {
      debugPrint("Error inferensi: $e");
      setState(() { _isLoading = false; _hideWatermark = false; });
    }
  }

  Map<String, String> _parseAlternative(String rawString) {
    var parts = rawString.trim().split(' (');
    if (parts.length >= 2) {
      return {'char': parts[0].trim(), 'percent': parts[1].replaceAll(')', '').trim()};
    }
    return {'char': '-', 'percent': '0%'};
  }

  void _showResultDialog(String predictedChar, double confidence, int stars, List<String> splitResults) async {
    if (stars > 0) {
      final player = AudioPlayer();
      await player.play(AssetSource('sounds/bell.mp3'));
    }

    String letterName = kHijaiahNames[predictedChar] ?? 'Tidak diketahui';
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        elevation: 15,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFE89A3D).withOpacity(0.5), width: 4),
            boxShadow: [
              BoxShadow(color: const Color(0xFFE89A3D).withOpacity(0.2), blurRadius: 20, spreadRadius: 5)
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFFE89A3D),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                ),
                child: const Text(
                  '✨ Hasil Prediksi ✨',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star_rounded, color: stars >= 1 ? Colors.amber : Colors.grey.shade300, size: 80),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Transform.translate(
                            offset: const Offset(0, -15),
                            child: Icon(Icons.star_rounded, color: stars >= 2 ? Colors.amber : Colors.grey.shade300, size: 75),
                          ),
                        ),
                        Icon(Icons.star_rounded, color: stars >= 3 ? Colors.amber : Colors.grey.shade300, size: 55),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 90,
                                child: Center(
                                  child: Transform.translate(
                                    offset: Offset(0, getOffsetForChar(predictedChar)),
                                    child: Text(
                                      predictedChar,
                                      style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w900, fontFamily: 'Amiri', color: Color(0xFF2B2D42), height: 1),
                                    ),
                                  ),
                                ),
                              ),
                              Text(letterName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF2B2D42))),
                              const SizedBox(height: 2),
                              Text('Terdeteksi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              border: Border.all(color: Colors.orange.shade300, width: 3),
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: Column(
                              children: [
                                Text('${confidence.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFFE89A3D))),
                                Text('Akurasi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    if (widget.targetLetter == null && splitResults.length > 2)
                      Container(
                        margin: const EdgeInsets.only(top: 32.0),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue.shade100, width: 2)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.analytics_rounded, size: 20, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text('Kemungkinan Lain:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.blue.shade800)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildAlternativeRow('1.', _parseAlternative(splitResults[1])),
                            const SizedBox(height: 8),
                            _buildAlternativeRow('2.', _parseAlternative(splitResults[2])),
                          ],
                        ),
                      ),

                    const SizedBox(height: 32),
                    
                    if (widget.targetLetter != null && stars > 0) ...[
                      SizedBox(
                        width: double.infinity, height: 55, 
                        child: ElevatedButton(
                          onPressed: () { 
                            HapticFeedback.lightImpact(); 
                            Navigator.pop(context); 
                            _nextLetter(); 
                          }, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text(
                            'Lanjut Huruf Berikutnya', 
                            textAlign: TextAlign.center, 
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white) 
                          )
                        )
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    SizedBox(
                      width: double.infinity, height: 55, 
                      child: ElevatedButton(
                        onPressed: () { HapticFeedback.lightImpact(); Navigator.pop(context); }, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE89A3D),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(stars > 0 ? 'Tutup' : 'Coba Lagi', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white))
                      )
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

  Widget _buildAlternativeRow(String number, Map<String, String> data) {
    String name = kHijaiahNames[data['char']] ?? '';
    double progress = double.tryParse(data['percent']!.replaceAll('%', '')) ?? 0.0;
    progress = progress / 100;

    return Row(
      children: [
        SizedBox(width: 25, child: Text(number, style: const TextStyle(fontWeight: FontWeight.bold))),
        SizedBox(width: 60, child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
        SizedBox(width: 30, child: Text(data['char']!, style: const TextStyle(fontFamily: 'Amiri', fontSize: 22, fontWeight: FontWeight.bold))),
        
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade300, 
                color: Colors.blue.shade400, 
                minHeight: 10, 
              ),
            ),
          ),
        ),
        
        SizedBox(width: 45, child: Text(data['percent']!, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600, fontSize: 13))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String namaFile = kHijaiahNames[_currentLetter]!.toLowerCase();
    
    LayoutControl layout = kLayoutControls[_currentLetter] ?? const LayoutControl(scale: 1.2, offsetY: 0.0);
    
    WatermarkConfig config = WatermarkConfig(
      imagePath: 'assets/watermarks/$namaFile.svg', 
      scale: layout.scale, 
      offsetY: layout.offsetY,
    );

    return Scaffold(
      backgroundColor: kBgColor,
     appBar: AppBar(
        toolbarHeight: 70, 
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () { 
              HapticFeedback.lightImpact(); 
              ScaffoldMessenger.of(context).clearSnackBars(); // Hapus sisa snackbar saat keluar halaman
              Navigator.pop(context); 
            },
            child: Container(decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: kSecondaryColor.withOpacity(0.2), blurRadius: 5)]), child: const Icon(Icons.arrow_back_rounded, color: kRedColor, size: 28)),
          ),
        ),
        title: Text(widget.targetLetter == null ? 'Papan Bebas' : 'Ayo Tulis Huruf\nHijaiah Sambung!', textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2B2D42), fontSize: 18, height: 1.2)),
        backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
        actions: [
          if (widget.targetLetter != null) 
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(children: [
                IconButton(onPressed: _prevLetter, icon: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: kPrimaryColor.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.arrow_back_ios_rounded, color: kPrimaryColor, size: 18))), 
                IconButton(onPressed: _nextLetter, icon: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: kPrimaryColor.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.arrow_forward_ios_rounded, color: kPrimaryColor, size: 18)))
              ]),
            ),
        ],
      ),
      
      // PERHATIKAN: Bagian ini sudah diubah menggunakan Stack
      body: Stack(
        children: [
          // Lapis Bawah: Layar Utama Drawing kamu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: kSecondaryColor, width: 6),
                      boxShadow: [BoxShadow(color: kSecondaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          RepaintBoundary(
                            key: _canvasKey,
                            child: Container(
                              color: Colors.white,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (widget.targetLetter != null && !_hideWatermark)
                                    Transform.translate(
                                      offset: Offset(0, config.offsetY), 
                                      child: Transform.scale(
                                        scale: config.scale, 
                                        child: Container(
                                          padding: const EdgeInsets.all(24.0), 
                                          alignment: Alignment.center,
                                          child: SvgPicture.asset(
                                            config.imagePath, 
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Signature(controller: _controller, backgroundColor: Colors.transparent),
                                ],
                              ),
                            ),
                          ),
                          // Animasi scanner lama (AnimatedBuilder) sudah dihapus dari sini!
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16), 
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () { HapticFeedback.lightImpact(); setState(() => _controller.undo()); },
                      icon: const Icon(Icons.undo, color: Colors.orange),
                      label: const Text('Undo', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                    ),
                    
                    if (widget.targetLetter != null) ...[
                      const SizedBox(width: 16),
                      TextButton.icon(
                        onPressed: _showLetterGuideSheet,
                        icon: const Icon(Icons.menu_book_rounded, color: Colors.blue),
                        label: const Text('Panduan', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      ),
                    ],

                    const SizedBox(width: 16), 
                    TextButton.icon(
                      onPressed: () { HapticFeedback.mediumImpact(); setState(() => _controller.clear()); },
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      label: const Text('Hapus', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _classify,
                    icon: const Icon(Icons.auto_awesome_rounded, size: 24),
                    label: const Text('Cek Hurufku!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const Spacer(),

                Container(
                  width: double.infinity, padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.amber.shade200, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lightbulb_rounded, color: Colors.orange, size: 24),
                          const SizedBox(width: 8),
                          Text('Tips Menulis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.orange.shade800)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTipItem('1', 'Gunakan jari atau Stylus Pen.'),
                      const SizedBox(height: 8),
                      _buildTipItem('2', 'Gambar mulai dari sisi kanan ke kiri.'),
                      const SizedBox(height: 8),
                      _buildTipItem('3', 'Ikuti garis titik-titik dengan teliti.'),
                      const SizedBox(height: 8),
                      _buildTipItem('4', 'Pastikan goresan menyambung dengan titik selanjutnya.'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          
          // Lapis Atas: Menutup layar dengan KidsAnalyzerLoader saat tombol Cek dipencet
          if (_isLoading)
            const Positioned.fill(
              child: KidsAnalyzerLoader(message: "Wah, sedang diperiksa..."),
            ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$number. ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
        Expanded(child: Text(text, style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w500))),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose(); 
    _tfliteService.dispose(); 
    super.dispose();
  }
}