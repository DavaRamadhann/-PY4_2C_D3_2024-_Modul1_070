import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/log_model.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);

  LogController() {
    loadFromStorage();
  }

  void addLog(String title, String desc, String category) {
    final newLog = LogModel(
      title: title,
      description: desc,
      category: category,
      timestamp: DateTime.now(),
    );
    logsNotifier.value = [...logsNotifier.value, newLog];
    saveToStorage();
  }

  void updateLog(int index, String title, String desc, String category) {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final oldLog = currentLogs[index];

    currentLogs[index] = LogModel(
      title: title,
      description: desc,
      category: category,
      timestamp: oldLog.timestamp, // Waktu asli tetap dipertahankan
    );
    logsNotifier.value = currentLogs;
    saveToStorage();
  }

  void deleteLog(int index) {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    currentLogs.removeAt(index);
    logsNotifier.value = currentLogs;
    saveToStorage();
  }

  // Fitur Undo
  void undoDelete(int index, LogModel log) {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    currentLogs.insert(index, log);
    logsNotifier.value = currentLogs;
    saveToStorage();
  }

  Future<void> saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> mapList =
        logsNotifier.value.map((log) => log.toMap()).toList();
    final String jsonString = jsonEncode(mapList);
    await prefs.setString('user_logs', jsonString);
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('user_logs');

    if (jsonString != null) {
      final List<dynamic> decodedList = jsonDecode(jsonString);
      logsNotifier.value = decodedList
          .map((item) => LogModel.fromMap(item))
          .toList();
    }
  }
}