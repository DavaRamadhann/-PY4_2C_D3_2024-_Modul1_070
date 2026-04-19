import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../main.dart'; // Akses ke variabel global cameras

class VisionController extends ChangeNotifier with WidgetsBindingObserver {
  CameraController? controller;
  bool isInitialized = false;
  String? errorMessage;
  
  // UX Enhancement: Flash & Overlay State
  bool isFlashOn = false; 
  bool isOverlayActive = true; 

  VisionController() {
    // Mendaftarkan observer agar bisa memantau status aplikasi (Lifecycle)
    WidgetsBinding.instance.addObserver(this);
    initCamera();
  }

  Future<void> initCamera() async {
    try {
      if (cameras.isEmpty) {
        errorMessage = "Tidak ada sensor kamera yang terdeteksi.";
        notifyListeners();
        return;
      }

      // Memilih Kamera Belakang (Index 0)
      controller = CameraController(
        cameras[0],
        ResolutionPreset.medium, // Keseimbangan antara akurasi AI & performa
        enableAudio: false,      // Kita hanya butuh visual untuk deteksi jalan
      );

      await controller!.initialize();
      isInitialized = true;
      errorMessage = null;
    } catch (e) {
      errorMessage = "Gagal menginisialisasi kamera: $e";
    }
    notifyListeners();
  }

  // UX Enhancement: Kontrol Senter (Flashlight API)
  Future<void> toggleFlash() async {
    if (controller != null && controller!.value.isInitialized) {
      isFlashOn = !isFlashOn;
      await controller!.setFlashMode(
        isFlashOn ? FlashMode.torch : FlashMode.off
      );
      notifyListeners();
    }
  }

  // UX Enhancement: Kontrol Layering Digital
  void toggleOverlay() {
    isOverlayActive = !isOverlayActive;
    notifyListeners();
  }

  // Mengambil gambar dari sensor kamera
  Future<XFile?> takePicture() async {
    if (controller == null || !controller!.value.isInitialized) {
      return null;
    }
    if (controller!.value.isTakingPicture) {
      return null;
    }
    try {
      final XFile file = await controller!.takePicture();
      return file;
    } on CameraException catch (e) {
      errorMessage = "Gagal mengambil gambar: $e";
      notifyListeners();
      return null;
    }
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // Jika controller belum ada atau belum siap, abaikan
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Melepaskan resource kamera saat aplikasi tidak terlihat
      cameraController.dispose();
      isInitialized = false;
      notifyListeners();
    } else if (state == AppLifecycleState.resumed) {
      // Menginisialisasi ulang saat pengguna kembali ke aplikasi
      initCamera();
    }
  }

  @override
  void dispose() {
    // Menghapus observer agar tidak terjadi memory leak
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }
}
