# Alify: Hijaiah Character Classification

Aplikasi berbasis *mobile* untuk mengklasifikasikan huruf Hijaiah tulisan tangan secara *real-time* menggunakan model *deep learning* hibrida **CNN-LSTM**. Proyek ini dikembangkan sebagai bagian dari Tugas Akhir (Skripsi) di program studi Informatika, Universitas Internasional Semen Indonesia (UISI).

## 🚀 Fitur Utama

* **Kanvas Input Dinamis:** Memungkinkan pengguna untuk menggambar huruf Hijaiah secara langsung di layar (*drawing screen*).
* **Inferensi *On-Device* Cepat:** Proses pengenalan karakter dilakukan langsung di dalam perangkat (*edge AI*) tanpa memerlukan koneksi internet, mengandalkan model klasifikasi CNN-LSTM yang telah dioptimalkan.
* **Panduan Penulisan Interaktif:** Dilengkapi dengan *dynamic disclaimer* dan *bottom sheet* panduan yang secara cerdas hanya muncul untuk mengedukasi penulisan huruf-huruf "non-sambung" (misalnya memberikan konteks struktural pada huruf 'Ba').
* **Antarmuka Minimalis:** Desain antarmuka (UI) yang bersih, profesional, dan bebas dari *bug* tumpukan notifikasi (*snackbars*), memastikan pengalaman belajar yang lancar.

## 🛠️ Teknologi dan Arsitektur

Proyek ini dibangun menggunakan *stack* teknologi berikut:
* **Frontend/Mobile Framework:** [Flutter](https://flutter.dev/) (Dart)
* **Arsitektur Machine Learning:** Convolutional Neural Network (CNN) dipadukan dengan Long Short-Term Memory (LSTM) untuk analisis pola spasial dan sekuensial guratan tulisan tangan.
* **Integrasi Model:** TensorFlow Lite (melalui `tflite_flutter` dan integrasi *Native Development Kit* / NDK).

## 📂 Navigasi Kode Utama

* `lib/screens/drawing_screen.dart`: Merupakan modul inti (*core*) aplikasi yang menangani *input* sentuhan (*touch events*) pada kanvas dan meneruskan data koordinat/citra ke mesin inferensi (*inference engine*).
* `lib/screens/landing_screen.dart` & `menu_screen.dart`: Mengelola navigasi utama dan presentasi awal aplikasi.
* `lib/screens/learning_list_screen.dart`: Menyajikan daftar modul pembelajaran atau daftar karakter Hijaiah yang tersedia.

## ⚙️ Persyaratan Sistem (*Build Requirements*)

Untuk melakukan *compile* dan *build* dari *source code* ini ke bentuk APK atau aplikasi iOS, pastikan lingkungan pengembangan telah memenuhi syarat berikut:
* Flutter SDK versi stabil terbaru.
* Android SDK dan **Android NDK** (wajib untuk membangun modul bahasa C/C++ yang dibutuhkan oleh ekstensi TFLite).
* Direkomendasikan menggunakan macOS (Apple Silicon / M1) atau sistem operasi setara dengan dukungan *toolchain* Android dan XCode.

---
**Pengembang:**
**Ahmad Agustio Fathoni** | Informatika - UISI
