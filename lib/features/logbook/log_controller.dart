import 'package:flutter/material.dart';
import 'package:logbook_app_070/features/logbook/models/log_model.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);

  void addLog(String title, String desc) {
    final newLog = LogModel(
      title: title,
      description: desc,
      timestamp: DateTime.now(),
    );
    logsNotifier.value = [...logsNotifier.value, newLog];
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
  }

  void deleteLog(int index) {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    currentLogs.removeAt(index);
    logsNotifier.value = currentLogs;
  }
}