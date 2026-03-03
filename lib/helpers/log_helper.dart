import 'dart:io'; // Tambahan untuk operasi File System
import 'dart:developer' as dev;
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LogHelper {
  static Future<void> writeLog(
    String message, {
    String source = "Unknown",
    int level = 2,
  }) async {
    final int configLevel = int.tryParse(dotenv.env['LOG_LEVEL'] ?? '2') ?? 2;
    final String muteList = dotenv.env['LOG_MUTE'] ?? '';

    if (level > configLevel) return;
    if (muteList.split(',').contains(source)) return;

    try {
      String timestamp = DateFormat('HH:mm:ss').format(DateTime.now());
      String dateFile = DateFormat('dd-MM-yyyy').format(DateTime.now());
      String label = _getLabel(level);
      String color = _getColor(level);

      // 1. Output ke Debug Console
      dev.log(message, name: source, time: DateTime.now(), level: level * 100);

      // 2. Output ke Terminal
      print('$color[$timestamp][$label][$source] -> $message\x1B[0m');

      // 3. HOTS TASK 4: Menulis ke File Fisik di folder /logs
      // Format yang tersimpan tanpa warna agar teksnya bersih saat dibaca
      final String plainLogEntry = '[$timestamp][$label][$source] -> $message\n';
      
      final directory = Directory('logs');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final file = File('logs/$dateFile.log');
      await file.writeAsString(plainLogEntry, mode: FileMode.append);

    } catch (e) {
      dev.log("Logging failed: $e", name: "SYSTEM", level: 1000);
    }
  }

  static String _getLabel(int level) {
    switch (level) {
      case 1:
        return "ERROR";
      case 2:
        return "INFO";
      case 3:
        return "VERBOSE";
      default:
        return "LOG";
    }
  }

  static String _getColor(int level) {
    switch (level) {
      case 1:
        return '\x1B[31m'; // Merah
      case 2:
        return '\x1B[32m'; // Hijau
      case 3:
        return '\x1B[34m'; // Biru
      default:
        return '\x1B[0m';
    }
  }
}