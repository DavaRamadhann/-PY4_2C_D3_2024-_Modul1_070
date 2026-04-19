# Logbook App 070 - Smart Patrol Vision (ETS Proyek 4 x PCD)

Aplikasi mobile Flutter ini merupakan integrasi sistem dari **Proyek 4: Mobile Development** yang disatukan dengan **Pengolahan Citra Digital (PCD)** untuk memenuhi Tugas Evaluasi Tengah Semester (ETS). 

Aplikasi ini mendemonstrasikan sistem lapor kerusakan/logbook yang digabungkan dengan antarmuka visi pintar (Smart Vision), di mana pemrosesan matriks gambar seperti Konvolusi (Edge Detection, Sharpen) dan Histogram Equalization dilakukan secara murni (*offline computing*) di lapisan perangkat seluler (Dart Isolates).

---

## ✨ Fitur Utama

1. **Authentication & Cloud Database (MongoDB + Hive)**
   Sistem login dan basis data *cloud* yang terintergrasi menggunakan *MongoDB* dengan backup lokal menggunakan *Hive*.
2. **Camera Sensor Tracking**
   Menangkap data video secara konstan menggunakan Camera API dari perangkat mobile, diselimuti layer *digital bounding-box marker* untuk pemindaian presisi tinggi.
3. **PCD Engine (Digital Image Processing)**
   Logika OpenCV FastAPI yang di-_porting_ jalannya secara *Native Offline Dart*:
   - Konvolusi Ketajaman (*Sharpen Kernel* 3x3)
   - Pendeteksi Tepi (*Sobel Edge Detection*)
   - Blemish/Noise Remover (*Average Blur*)
   - Perata Warna (*Histogram Equalization*)
   - Manipulasi Warna (Grayscale & Brightness Modifiers)

---

## 🛠 Instalasi dan Persiapan (*Setup*)

Sebelum menjalankan aplikasi, pastikan komputer/laptop Anda telah terpasang dependensi dasar pengembangan Mobile:
- **Flutter SDK** versi 3.10.x atau ke atas.
- **Dart SDK**.
- **Android Studio** atau **VS Code** (serta ekstensi Flutter/Dart terinstal).
- Ekstrak atau *Clone* repositori ini ke memori internal Anda.

### 1. Inisialisasi Environment Database
Aplikasi ini dihubungkan dengan MongoDB dan memerlukan *Environment Variable* (`.env`).
- Pastikan Anda membuat / menaruh file bernama `.env` di folder utama aplikasi ini (sejajar dengan folder `lib`).
- Konfigurasikan koneksi `.env` seperti `MONGO_URL=` (sesuaikan dengan tugas modul).

### 2. Unduh Dependensi
Buka Terminal/CMD/PowerShell, navigasikan ke *root* folder proyek ini, dan jalankan perintah:
```bash
flutter pub get
```
*Perintah ini akan mengunduh paket besar seperti `camera`, `mongo_dart`, dan module kalkulasi `image` otomatis.*

### 3. Kompilasi dan Jalankan ke Perangkat
Siapkan perangkat *smartphone* asli via kabel USB (disarankan) atau nyalakan Emulator Android Anda, lalu jalankan:
```bash
flutter run
```

---

## 🚀 Panduan Ringkas Penggunaan

1. Buka aplikasi dan lakukan Autentikasi / _Login_.
2. Pilih navigasi **Smart-Patrol Vision**.
3. Di dalam vizor kamera, arahkan HP Anda ke area target dan tekan tombol ikon **Kamera Lingkaran Putih** di bagian bawah.
4. Anda akan dimasukkan ke mode Edit (**PCD Preview**).
5. Pada bagian bawah, **geser (scroll) *PCD toolbar*** horizontal untuk mencoba filter-filter yang disediakan:
   - Pilih **[Edge Detect]** untuk menemukan garis tepian objek menonjol.
   - Pilih **[Hist. Equalize]** untuk menerangkan gambar gelap terkurasi secara otomatis.
   - (Proses pengeditan filter memakan waktu komputasi 1-3 detik per foto dan memunculkan *loading*).
6. Tekan tanda **[Centang]** di ujung kanan atas layar untuk kembali melanjutkan aktivitas logbook Anda!

---
