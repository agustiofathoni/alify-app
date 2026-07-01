import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteService {
  Interpreter? _interpreter;
  List<String> _labels = [];

  // 1. Memuat Model dan Label JSON ke dalam memori
  Future<void> initialize() async {
    try {
      final modelData = await rootBundle.load('assets/models/model_id_9.tflite');
      final bytes = modelData.buffer.asUint8List();
      _interpreter = Interpreter.fromBuffer(bytes);

      final jsonString = await rootBundle.loadString('assets/models/labels.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _labels = jsonList.map((e) => e.toString()).toList();
      
      if (_labels.length != 28) {
        throw Exception("Jumlah label di JSON tidak sesuai (harus 28 kelas).");
      }
    } catch (e) {
      throw Exception("Gagal inisialisasi AI: $e");
    }
  }

  // 2. Proses Klasifikasi
  Future<String> classifyImage(Uint8List imageBytes) async {
    if (_interpreter == null || _labels.isEmpty) {
      return "Model belum siap!";
    }

    // 1. Decode gambar mentah dari kanvas Flutter
    img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) return "Gagal membaca gambar!";

    // ==========================================
    // ALGORITMA AUTO-CROP (MEMBUANG WHITESPACE)
    // ==========================================
    int minX = originalImage.width;
    int minY = originalImage.height;
    int maxX = 0;
    int maxY = 0;

    // Pindai seluruh piksel untuk mencari titik tinta terluar
    for (int y = 0; y < originalImage.height; y++) {
      for (int x = 0; x < originalImage.width; x++) {
        final pixel = originalImage.getPixel(x, y);
        // Kanvas kita transparan, jadi kita cari piksel yang Alpha-nya > 0 (ada tintanya)
        if (pixel.a > 0) {
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
      }
    }

    // Tambahkan sedikit padding buatan (safety margin) agar tidak terpotong ekstrem 
    // seperti pada contoh gambar dataset Anda yang masih punya sedikit ruang putih
    int padding = 20; 
    minX = (minX - padding).clamp(0, originalImage.width - 1);
    minY = (minY - padding).clamp(0, originalImage.height - 1);
    maxX = (maxX + padding).clamp(0, originalImage.width - 1);
    maxY = (maxY + padding).clamp(0, originalImage.height - 1);

    // Potong gambar sesuai batas tinta terluar
    img.Image croppedImage = img.copyCrop(
      originalImage,
      x: minX,
      y: minY,
      width: maxX - minX,
      height: maxY - minY,
    );
    // ==========================================

    // 2. Resize gambar yang sudah dipotong agar proporsional
    // Karena gambar dataset Anda persegi, kita resize sisi terpanjangnya ke 200px
    img.Image resizedImage;
    if (croppedImage.width > croppedImage.height) {
      resizedImage = img.copyResize(croppedImage, width: 200);
    } else {
      resizedImage = img.copyResize(croppedImage, height: 200);
    }
    
    // 3. MANUAL PAD: Buat kanvas putih murni 224x224 (Sesuai input model)
    img.Image finalImage = img.Image(width: 224, height: 224);
    img.fill(finalImage, color: img.ColorRgb8(255, 255, 255));
    
    // 4. Tempel tulisan tepat di tengah kanvas 224x224
    int offsetX = (224 - resizedImage.width) ~/ 2;
    int offsetY = (224 - resizedImage.height) ~/ 2;
    img.compositeImage(finalImage, resizedImage, dstX: offsetX, dstY: offsetY);

    // 5. Normalisasi Matriks untuk Model TFLite
    var inputFloatArray = List.generate(1, (i) => List.generate(224, (y) => List.generate(224, (x) {
      final pixel = finalImage.getPixel(x, y);
      return [
        pixel.r.toDouble(), 
        pixel.g.toDouble(), 
        pixel.b.toDouble()
      ];
    })));

    var outputArray = List.generate(1, (i) => List.filled(28, 0.0));
    _interpreter!.run(inputFloatArray, outputArray);
    
    // 6. Algoritma Sorting Top 3 
    final softmaxProbabilities = outputArray[0];
    List<Map<String, dynamic>> rankedResults = [];

    for (int i = 0; i < softmaxProbabilities.length; i++) {
      rankedResults.add({
        'label': _labels[i],
        'confidence': softmaxProbabilities[i] * 100,
      });
    }

    rankedResults.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));

    String juara1 = "${rankedResults[0]['label']} (${rankedResults[0]['confidence'].toStringAsFixed(1)}%)";
    String juara2 = "${rankedResults[1]['label']} (${rankedResults[1]['confidence'].toStringAsFixed(1)}%)";
    String juara3 = "${rankedResults[2]['label']} (${rankedResults[2]['confidence'].toStringAsFixed(1)}%)";
    
    return "$juara1|$juara2|$juara3";
  }

  void dispose() {
    _interpreter?.close();
  }
}