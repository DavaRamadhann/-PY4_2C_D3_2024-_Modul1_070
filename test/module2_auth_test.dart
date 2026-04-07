import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_070/features/auth/login_controller.dart';

void main() {
  group('Module 2 - LoginController (Homework)', () {
    late LoginController controller;

    setUp(() {
      controller = LoginController(); // Arrange
    });

    test('TC01_Auth: Harus sukses login dengan akun valid', () {
      final result = controller.login('dava', '123'); // Act
      expect(result, isNotNull); // Assert
      expect(result!['role'], 'Ketua');
    });

    test('TC02_Auth: Harus ditolak jika username tidak ada', () {
      final result = controller.login('hacker', '123'); // Act
      expect(result, isNull); // Assert
    });

    test('TC03_Auth: Harus ditolak jika password salah', () {
      final result = controller.login('dava', '999'); // Act
      
      expect(result, isNull, reason: 'Test Gagal: Aplikasi membiarkan password salah masuk!'); // Assert
    });
  });
}
