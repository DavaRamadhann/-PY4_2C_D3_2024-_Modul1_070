import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logbook_app_070/features/counter/counter_controller.dart';

void main() {
  group('Module 1 - CounterController (Test TC01 - TC10)', () {
    late CounterController controller;
    const username = "admin";

    // (1) SETUP: Dijalankan sebelum tiap test case
    setUp(() async {
      SharedPreferences.setMockInitialValues({}); // mock storage agar tidak error
      controller = CounterController();
      await controller.loadAll(username);
    });

    test('TC01: initial value should be 0', () {
      expect(controller.value, 0);
    });

    test('TC02: setStep should change step value', () {
      controller.setStep(5);
      expect(controller.step, 5);
    });

    test('TC03: setStep should ignore negative value', () {
      controller.setStep(3);
      controller.setStep(-1);
      expect(controller.step, 3);
    });

    test('TC04: increment should increase counter based on step', () {
      controller.setStep(2);
      controller.increment(username);
      expect(controller.value, 2);
    });

    test('TC05: decrement should decrease counter based on step', () {
      controller.setStep(2);
      controller.increment(username);
      controller.decrement(username);
      expect(controller.value, 0);
    });

    // 🔴 INI TEST CASE YANG AKAN SENGAJA FAIL UNTUK SCREENSHOT "BUG REPORT" ANDA
    test('TC06: decrement should not go below zero', () {
      controller.setStep(5);
      controller.decrement(username); // Saat ini logikanya nilai akan jadi -5
      
      // Padahal ekspektasi tidak boleh bolong ke negatif (harus 0)
      expect(controller.value, 0, reason: 'Ekspektasi 0, tapi malah dapat ${controller.value} (tembus negatif)');
    });

    test('TC07: reset should set counter to zero', () {
      controller.increment(username);
      controller.reset(username);
      expect(controller.value, 0);
    });

    test('TC08: history should record actions', () {
      controller.increment(username);
      expect(controller.history.isNotEmpty, true);
    });

    test('TC09: history should not exceed 5 items', () {
      for (int i = 0; i < 6; i++) {
        controller.increment(username);
      }
      expect(controller.history.length, lessThanOrEqualTo(5)); // Harus mentok di 5
    });

    test('TC10: counter should persist using SharedPreferences', () async {
      controller.setStep(3);
      controller.increment(username);
      
      final newController = CounterController(); // Bikin objek baru
      await newController.loadAll(username); // Muat memori
      
      expect(newController.value, 3);
    });
  });
}
