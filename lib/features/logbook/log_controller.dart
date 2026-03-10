import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;
import 'models/log_model.dart';
import '../../services/mongo_service.dart';
import '../../helpers/log_helper.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<String?> errorNotifier = ValueNotifier(null);

  final Box<LogModel> _myBox = Hive.box<LogModel>('offline_logs');

  /// 1. LOAD DATA (Offline-First Strategy)
  Future<void> loadLogs(String teamId) async {
    // Ambil data dari Hive instan
    logsNotifier.value = _myBox.values.toList();

    // Sync dari Cloud
    try {
      final cloudData = await MongoService().getLogs(teamId);

      // Sinkronisasi data lokal ke Cloud jika ada catatan yang dibuat saat Offline
      final syncedCount = await _syncOfflineData(cloudData);

      final finalData = syncedCount > 0 
          ? await MongoService().getLogs(teamId) // Fetch ulang jika ada data baru masuk Cloud
          : cloudData;

      await _myBox.clear();
      await _myBox.addAll(finalData);

      logsNotifier.value = finalData;

      await LogHelper.writeLog(
        "SYNC: Data berhasil diperbarui dari Atlas",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "OFFLINE: Menggunakan data cache lokal - $e",
        level: 2,
      );
    }
  }

  /// 2. ADD DATA
  Future<void> addLog({
    required String title,
    required String description,
    required String authorId,
    required String teamId,
    required bool isPublic,
    required String category,
  }) async {
    final newLog = LogModel(
      id: ObjectId().oid,
      title: title,
      description: description,
      date: DateTime.now().toString(),
      authorId: authorId,
      teamId: teamId,
      isPublic: isPublic,
      category: category,
    );

    // ACTION 1: Simpan ke Hive (Instan)
    await _myBox.add(newLog);
    logsNotifier.value = [...logsNotifier.value, newLog];

    // ACTION 2: Kirim ke Cloud
    try {
      await MongoService().insertLog(newLog);
      await LogHelper.writeLog(
        "SUCCESS: Data tersinkron ke Cloud",
        source: "log_controller.dart",
      );
    } catch (e) {
      await LogHelper.writeLog(
        "WARNING: Data tersimpan lokal, akan sinkron saat online",
        level: 1,
      );
    }
  }

  /// 3. UPDATE DATA
  Future<void> updateLog({
    required int index,
    required String title,
    required String description,
    required bool isPublic,
    required String category,
  }) async {
    final currentLog = logsNotifier.value[index];
    final updatedLog = LogModel(
      id: currentLog.id,
      title: title,
      description: description,
      date: currentLog.date,
      authorId: currentLog.authorId,
      teamId: currentLog.teamId,
      isPublic: isPublic,
      category: category,
    );

    // ACTION 1: Simpan Lokal
    final key = _myBox.keyAt(index);
    await _myBox.put(key, updatedLog);
    final newList = List<LogModel>.from(logsNotifier.value);
    newList[index] = updatedLog;
    logsNotifier.value = newList;

    // ACTION 2: Simpan Cloud
    try {
      await MongoService().updateLog(updatedLog);
    } catch (e) {
      await LogHelper.writeLog(
        "Gagal update cloud, tersimpan lokal: $e",
        level: 1,
      );
    }
  }

  /// 4. REMOVE DATA
  Future<void> removeLog(int index) async {
    final logToDelete = logsNotifier.value[index];

    // Simpan Lokal
    final key = _myBox.keyAt(index);
    await _myBox.delete(key);
    final newList = List<LogModel>.from(logsNotifier.value);
    newList.removeAt(index);
    logsNotifier.value = newList;

    if (logToDelete.id != null) {
      try {
        await MongoService().deleteLog(ObjectId.fromHexString(logToDelete.id!));
      } catch (e) {
        await LogHelper.writeLog(
          "Gagal menghapus dari cloud: $e",
          level: 1,
        );
      }
    }
  }

  /// 5. SYNC OFFLINE DATA
  Future<int> _syncOfflineData(List<LogModel> cloudData) async {
    final cloudIds = cloudData.map((e) => e.id).toSet();
    final localData = _myBox.values.toList();
    
    int syncedCount = 0;
    for (var localLog in localData) {
      // Jika data lokal tidak ada di cloud, berarti dibuat saat offline!
      if (!cloudIds.contains(localLog.id)) {
        try {
          await MongoService().insertLog(localLog);
          syncedCount++;
        } catch (e) {
          // Gagal insert (mungkin koneksi putus lagi), biarkan di Hive
        }
      }
    }
    
    if (syncedCount > 0) {
      await LogHelper.writeLog(
        "SYNC: Berhasil mengunggah $syncedCount catatan offline ke Cloud!", 
        level: 2
      );
    }
    return syncedCount;
  }
}