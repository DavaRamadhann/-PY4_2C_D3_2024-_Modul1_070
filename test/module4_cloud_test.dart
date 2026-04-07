import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_070/features/logbook/models/log_model.dart';
import 'package:logbook_app_070/services/mongo_service.dart';

void main() {
  group('Module 4 - Cloud Service (Homework)', () {
    late MongoService service;

    setUp(() {
      service = MongoService();
    });

    test('TC01_Cloud: Proteksi Cloud melempar Exception jika title kosong', () async {
      final badLog = LogModel(title: '', description: 'Isi Text', authorId: 'USR1', teamId: 'TIM1', date: '');
      
      expect(
        () async => await service.insertLog(badLog),
        throwsA(predicate((e) => e.toString().contains("Title Kosong"))),
      );
    });

    test('TC02_Cloud: Proteksi Cloud melempar Exception jika teamId kosong', () async {
      final badTeamLog = LogModel(title: 'Rapat', description: 'Isi Text', authorId: 'USR1', teamId: '', date: '');
      
      expect(
        () async => await service.insertLog(badTeamLog),
        throwsA(predicate((e) => e.toString().contains("Team Kosong"))),
        reason: 'Sistem kebobolan! Team ID Kosong dibiarkan menembus Cloud',
      );
    });

    test('TC03_Cloud: Flow data valid diteruskan ke lapisan network Cloud', () async {
      final validLog = LogModel(title: 'Rapat Sukses', description: 'Isi Text', authorId: 'USR1', teamId: 'TIM1', date: '');
      
      expect(
        () async => await service.insertLog(validLog),
        throwsA(predicate((e) => !e.toString().contains("Kosong"))), // Lolos validasi String Kosong
      );
    });
  });
}
