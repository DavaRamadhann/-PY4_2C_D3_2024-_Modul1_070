import 'dart:convert'; // Untuk jsonEncode & jsonDecode
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/log_model.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);

  // Panggil load saat Controller pertama kali dibuat
  LogController() {
    loadFromStorage();
  }

  // --- CRUD FUNCTIONS ---

  void addLog(String title, String desc) {
    final newLog = LogModel(
      title: title,
      description: desc,
      timestamp: DateTime.now(),
    );
    logsNotifier.value = [...logsNotifier.value, newLog];
    saveToStorage(); // Simpan otomatis
  }

  void updateLog(int index, String title, String desc) {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final oldLog = currentLogs[index];

    currentLogs[index] = LogModel(
      title: title,
      description: desc,
      timestamp: oldLog.timestamp,
    );
    logsNotifier.value = currentLogs;
    saveToStorage(); // Simpan otomatis
  }

  void deleteLog(int index) {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    currentLogs.removeAt(index);
    logsNotifier.value = currentLogs;
    saveToStorage(); // Simpan otomatis
  }

  // --- PERSISTENCE (TASK 4) ---

  Future<void> saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    // 1. Ubah List<LogModel> menjadi List<Map>
    final List<Map<String, dynamic>> mapList = 
        logsNotifier.value.map((log) => log.toMap()).toList();
    
    // 2. Encode List<Map> menjadi String JSON
    final String jsonString = jsonEncode(mapList);

    // 3. Simpan ke SharedPreferences
    await prefs.setString('user_logs', jsonString);
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('user_logs');

    if (jsonString != null) {
      // 1. Decode String JSON menjadi List<dynamic>
      final List<dynamic> decodedList = jsonDecode(jsonString);

      // 2. Ubah setiap item menjadi LogModel dan masukkan ke Notifier
      logsNotifier.value = decodedList
          .map((item) => LogModel.fromMap(item))
          .toList();
    }
  }
}