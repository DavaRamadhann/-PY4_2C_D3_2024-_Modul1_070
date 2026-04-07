import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logbook_app_070/features/logbook/log_controller.dart';
import 'package:logbook_app_070/features/logbook/models/log_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  group('Module 3 - Save Data to Disk (Homework)', () {
    late LogController controller;
    late Directory tempDir;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      // Setup ruang dummy di disk untuk kelancaran Uji Hive
      tempDir = await Directory.systemTemp.createTemp('hive_test_dir');
      Hive.init(tempDir.path);
      Hive.registerAdapter(LogModelAdapter());
      await Hive.openBox<LogModel>('offline_logs');
    });

    tearDownAll(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    setUp(() {
      controller = LogController();
    });

    test('TC01_Disk: Eksekusi program dasar tidak crash', () async {
      await controller.addLog(
        title: 'Judul Rapat', description: 'Bahas Tampilan', 
        authorId: 'dava', teamId: 'tim-1', isPublic: false, category: 'Umum'
      );
      expect(true, true); // Assert
    });

    test('TC02_Disk: Data Update Memory / RAM harus bertambah', () async {
      final initialCount = controller.logsNotifier.value.length;
      await controller.addLog(
        title: 'Update Memory', description: 'Isi Text', 
        authorId: 'dava', teamId: 'tim-1', isPublic: false, category: 'Umum'
      );
      expect(controller.logsNotifier.value.length, initialCount + 1, reason: "Memori UI/Screen Gagal Bertambah!");
    });


    test('TC03_Disk: Data Tersimpan ke Local Hard-Disk (Hive)', () async {
      final box = Hive.box<LogModel>('offline_logs');
      final initialCount = box.length;
      await controller.addLog(
        title: 'Offline Data', description: 'Isi Text', 
        authorId: 'dava', teamId: 'tim-1', isPublic: false, category: 'Umum'
      );
      expect(box.length, initialCount + 1, reason: "Data Gagal Disimpan Permanen ke Disk!");
    });
  });
}
