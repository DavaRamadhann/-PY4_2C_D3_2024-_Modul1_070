import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_070/services/access_control_service.dart';
import 'package:logbook_app_070/features/logbook/models/log_model.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

void main() {
  group('RBAC Security Check (The Privacy Leak Test)', () {
    test('Private logs should NOT be visible to teammates', () {
      // 1. Setup Data
      final userA_Id = 'user_A_123';
      final userB_Id = 'user_B_456';
      final teamId = 'MEKTRA_KLP_01';

      final List<LogModel> allLogs = [
        LogModel(
          id: ObjectId().oid,
          title: 'Private Notes',
          description: 'Secret mechanical design',
          date: '2026-03-10',
          authorId: userA_Id, // Owner: User A
          teamId: teamId,
          isPublic: false, // PRIVATE
        ),
        LogModel(
          id: ObjectId().oid,
          title: 'Public Updates',
          description: 'Team mechanical update',
          date: '2026-03-10',
          authorId: userA_Id, // Owner: User A
          teamId: teamId,
          isPublic: true, // PUBLIC
        ),
      ];

      // 2. Action: User B (Teammate) fetches logs
      // The logic replicates what happens in log_view.dart where we filter the list.
      final userBRole = 'Anggota';
      final fetchedLogsForUserB = allLogs.where((log) {
        final isOwner = log.authorId == userB_Id;
        final canSee = AccessControlService.canPerform(
          userBRole,
          AccessControlService.actionRead,
          isOwner: isOwner,
          isPublic: log.isPublic,
        );
        return canSee;
      }).toList();

      // 3. Assert
      expect(fetchedLogsForUserB.length, 1);
      expect(fetchedLogsForUserB.first.title, 'Public Updates');
      
      // Ensure private log did not leak
      final privateLogsLeaked = fetchedLogsForUserB.where((log) => !log.isPublic).toList();
      expect(privateLogsLeaked.isEmpty, true, reason: "SYSTEM VULNERABLE: Private log leaked to teammate.");
    });

    test('Private logs SHOULD be visible to the Owner', () {
      // 1. Setup Data
      final userA_Id = 'user_A_123';
      final teamId = 'MEKTRA_KLP_01';

      final log = LogModel(
        id: ObjectId().oid,
        title: 'Private Notes',
        description: 'Secret mechanical design',
        date: '2026-03-10',
        authorId: userA_Id,
        teamId: teamId,
        isPublic: false,
      );

      // 2. Action: User A (Owner) fetches the log
      final userARole = 'Anggota';
      final isOwner = log.authorId == userA_Id;
      final canSee = AccessControlService.canPerform(
        userARole,
        AccessControlService.actionRead,
        isOwner: isOwner,
        isPublic: log.isPublic,
      );

      // 3. Assert
      expect(canSee, true, reason: "Owner should have access to their own private log.");
    });
  });
}
