import 'package:flutter/material.dart';
import 'models/log_model.dart';
import '../../services/mongo_service.dart';
import '../../helpers/log_helper.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<String?> errorNotifier = ValueNotifier(null);

  Future<void> loadFromDisk() async {
    try {
      errorNotifier.value = null; // Reset error
      final logs = await MongoService().getLogs();
      logsNotifier.value = logs;
      await LogHelper.writeLog(
        "Data berhasil dimuat dari Cloud",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      errorNotifier.value = "Gagal memuat data. Periksa koneksi internet Anda.";
      await LogHelper.writeLog(
        "Load error: $e",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }

  Future<void> addLog(String title, String description, String category) async {
    final newLog = LogModel(
      title: title,
      description: description,
      category: category,
      timestamp: DateTime.now(),
    );

    try {
      await MongoService().insertLog(newLog);
      await loadFromDisk();
    } catch (e) {
      await LogHelper.writeLog(
        "Gagal menambah data: $e",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }

  Future<void> updateLog(int index, String title, String description, String category) async {
    final currentLog = logsNotifier.value[index];
    final updatedLog = LogModel(
      id: currentLog.id,
      title: title,
      description: description,
      category: category,
      timestamp: currentLog.timestamp,
    );

    try {
      await MongoService().updateLog(updatedLog);
      await loadFromDisk();
    } catch (e) {
      await LogHelper.writeLog(
        "Gagal update data: $e",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }

  Future<void> removeLog(int index) async {
    final logToDelete = logsNotifier.value[index];
    if (logToDelete.id != null) {
      try {
        await MongoService().deleteLog(logToDelete.id!);
        await loadFromDisk();
      } catch (e) {
        await LogHelper.writeLog(
          "Gagal menghapus data: $e",
          source: "log_controller.dart",
          level: 1,
        );
      }
    }
  }
}