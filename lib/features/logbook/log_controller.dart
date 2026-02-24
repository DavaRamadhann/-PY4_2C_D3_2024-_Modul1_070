import 'package:flutter/material.dart';
import 'models/log_model.dart';

class LogController {
  // Menyimpan semua catatan (Task 2 masih pakai List biasa, belum reaktif)
  final List<LogModel> logs = [];

  // CREATE - Tambah catatan baru
  void addLog(String title, String description) {
    final newLog = LogModel(
      title: title,
      description: description,
      timestamp: DateTime.now().toString(),
    );
    logs.add(newLog);
  }

  // UPDATE - Edit catatan berdasarkan index
  void updateLog(int index, String title, String description) {
    logs[index] = LogModel(
      title: title,
      description: description,
      timestamp: DateTime.now().toString(),
    );
  }

  // DELETE - Hapus catatan berdasarkan index
  void removeLog(int index) {
    logs.removeAt(index);
  }
}