import 'package:flutter_dotenv/flutter_dotenv.dart';

class AccessControlService {
  static List<String> get availableRoles =>
      dotenv.env['APP_ROLES']?.split(',') ?? ['Anggota', 'Ketua'];

  static const String actionCreate = 'create';
  static const String actionRead = 'read';
  static const String actionUpdate = 'update';
  static const String actionDelete = 'delete';

  static bool canPerform(String role, String action, {bool isOwner = false, bool isPublic = false}) {
    if (action == actionCreate) return true;
    
    if (action == actionRead) {
      return isOwner || isPublic;
    }

    if (action == actionUpdate || action == actionDelete) {
      return isOwner;
    }

    return false;
  }
}
