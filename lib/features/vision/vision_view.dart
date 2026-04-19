import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:math';

import 'vision_controller.dart';
import 'damage_painter.dart';
import 'pcd_preview_view.dart';

class VisionView extends StatefulWidget {
  const VisionView({super.key});

  @override
  State<VisionView> createState() => _VisionViewState();
}

class _VisionViewState extends State<VisionView> {
  // Inisialisasi controller secara lokal untuk halaman ini
  late VisionController _visionController;
  
  bool _hasPermission = false;
  bool _isCheckingPermission = true;

  // Mock Detection State (Simulasi keluaran YOLO YOLO)
  Timer? _mockTimer;
  double _mockX = 0.25;
  double _mockY = 0.25;
  double _mockW = 0.4;
  double _mockH = 0.4;
  String _mockLabel = "[D40] POTHOLE";
  Color _mockColor = Colors.redAccent;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _visionController = VisionController();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.request();
    if (mounted) {
      setState(() {
        _hasPermission = status.isGranted;
        _isCheckingPermission = false;
      });
      if (_hasPermission) {
        _startMockDetection();
      }
    }
  }

  void _startMockDetection() {
    // Memindahkan kotak deteksi secara acak dengan timer setiap 3 detik
    _mockTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          // X dan Y berkisar antara 0.1 sampai 0.5 layar
          _mockX = 0.1 + _random.nextDouble() * 0.4;
          _mockY = 0.1 + _random.nextDouble() * 0.4;
          
          // Ganti klasifikasi untuk simulasi style & branding
          if (_random.nextBool()) {
            _mockLabel = "[D40] POTHOLE";
            _mockColor = Colors.redAccent; // Kerusakan Berat
          } else {
            _mockLabel = "[D00] LONGITUDINAL CRACK";
            _mockColor = Colors.orangeAccent; // Kerusakan Ringan
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _mockTimer?.cancel();
    _visionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermission) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text("Memeriksa Izin Hardware...", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    if (!_hasPermission) {
      return Scaffold(
        appBar: AppBar(title: const Text("Smart-Patrol Vision")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text("Akses Kamera Ditolak Menggantung", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  openAppSettings();
                },
                child: const Text("Buka Pengaturan OS"),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Smart-Patrol Vision", 
          style: TextStyle(fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.black45,
        elevation: 0,
        actions: [
          // TOMBOL KONTROL HARDWARE & DIGITAL LAYER
          ListenableBuilder(
            listenable: _visionController,
            builder: (context, _) => IconButton(
              icon: Icon(
                _visionController.isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: _visionController.isFlashOn ? Colors.yellow : Colors.white,
              ),
              onPressed: () => _visionController.toggleFlash(),
            ),
          ),
          ListenableBuilder(
            listenable: _visionController,
            builder: (context, _) => IconButton(
              icon: Icon(
                _visionController.isOverlayActive ? Icons.layers : Icons.layers_clear,
                color: _visionController.isOverlayActive ? Colors.greenAccent : Colors.white54,
              ),
              onPressed: () => _visionController.toggleOverlay(),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _visionController,
        builder: (context, child) {
          // Tampilkan loading jika kamera belum siap
          if (!_visionController.isInitialized) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   CircularProgressIndicator(color: Colors.white),
                   SizedBox(height: 16),
                   Text("Menghubungkan ke Sensor Real-Time...", style: TextStyle(color: Colors.white)),
                ],
              ),
            );
          }
          
          return _buildVisionStack();
        },
      ),
    );
  }

  // The Stack Implementation
  Widget _buildVisionStack() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // LAYER 1: Kamera (Background RAW Image Data)
        Center(
          child: AspectRatio(
            aspectRatio: _visionController.controller!.value.aspectRatio,
            child: CameraPreview(_visionController.controller!),
          ),
        ),

        // LAYER 2: Digital Overlay (Foreground)
        if (_visionController.isOverlayActive)
          Positioned.fill(
            child: CustomPaint(
              painter: DamagePainter(
                normalizedX: _mockX,
                normalizedY: _mockY,
                normalizedWidth: _mockW,
                normalizedHeight: _mockH,
                label: _mockLabel,
                score: 0.95, // Simulasi akurasi yakin AI
                boundingBoxColor: _mockColor,
              ),
            ),
          ),

        // GUIDELINE: Static Visual Anchor (Simulasi crosshair)
        if (_visionController.isOverlayActive)
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.add, color: Colors.white30, size: 50),
              ),
            ),
          ),
          
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Memindai Kerusakan...",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          
        // CAPTURE BUTTON FOR PCD PROCESSING
        Positioned(
          bottom: 110,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: () async {
                final file = await _visionController.takePicture();
                if (file != null && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PcdPreviewView(imagePath: file.path),
                    ),
                  );
                }
              },
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black54, blurRadius: 10, spreadRadius: 2)
                  ]
                ),
                child: const Icon(Icons.camera_alt, size: 36, color: Colors.blueAccent),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
