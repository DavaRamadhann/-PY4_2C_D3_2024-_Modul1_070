import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'pcd_service.dart';

class PcdPreviewView extends StatefulWidget {
  final String imagePath;
  const PcdPreviewView({super.key, required this.imagePath});

  @override
  State<PcdPreviewView> createState() => _PcdPreviewViewState();
}

class _PcdPreviewViewState extends State<PcdPreviewView> {
  Uint8List? _originalBytes;
  Uint8List? _displayedBytes;
  bool _isProcessing = false;
  PcdFilterType _activeFilter = PcdFilterType.original;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    setState(() => _isProcessing = true);
    final file = File(widget.imagePath);
    final bytes = await file.readAsBytes();
    setState(() {
      _originalBytes = bytes;
      _displayedBytes = bytes;
      _isProcessing = false;
    });
  }

  Future<void> _applyFilter(PcdFilterType filterType) async {
    if (_originalBytes == null) return;
    if (_activeFilter == filterType) return; // sudah aktif
    
    setState(() {
      _isProcessing = true;
      _activeFilter = filterType;
    });

    try {
      // Menggunakan Compute untuk menjalankan algoritma matriks gambar 
      // yang berat pada Isolates (Background thread), agar layar tidak macet.
      final processedBytes = await compute(PCDService.processImage, {
        'imageBytes': _originalBytes!,
        'filterType': filterType,
      });

      if (mounted) {
        setState(() {
          _displayedBytes = processedBytes;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memproses gambar PCD: $e')),
        );
      }
    }
  }

  Widget _buildFilterButton(String label, PcdFilterType filterType) {
    final isActive = _activeFilter == filterType;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isActive,
        onSelected: (_) => _applyFilter(filterType),
        selectedColor: Colors.blueAccent,
        backgroundColor: Colors.grey[800],
        showCheckmark: false,
        labelStyle: TextStyle(
          color: isActive ? Colors.white : Colors.white70,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          letterSpacing: 0.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: BorderSide(
            color: isActive ? Colors.blueAccent : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Filter PCD'),
        backgroundColor: Colors.black45,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
               // Kembali ke kamera
               Navigator.pop(context);
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_displayedBytes != null)
                  InteractiveViewer(
                    child: Image.memory(
                      _displayedBytes!,
                      fit: BoxFit.contain,
                    ),
                  ),
                if (_isProcessing)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text("Menghitung Matriks Piksel...", 
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )
              ],
            ),
          ),
          // Toolbar Filters di bagian bawah
          Container(
            height: 80,
            color: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                _buildFilterButton('Original', PcdFilterType.original),
                _buildFilterButton('Grayscale', PcdFilterType.grayscale),
                _buildFilterButton('Brightness+', PcdFilterType.brightness),
                _buildFilterButton('Hist. Equalize', PcdFilterType.histogramEqualization),
                _buildFilterButton('Blur', PcdFilterType.averageBlur),
                _buildFilterButton('Sharpen', PcdFilterType.sharpen),
                _buildFilterButton('Edge Detect', PcdFilterType.edgeDetection),
              ],
            ),
          )
        ],
      ),
    );
  }
}
