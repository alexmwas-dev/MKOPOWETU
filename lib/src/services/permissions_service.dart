import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionsService {
  static Future<bool> requestAll() async {
    final statuses = await [
      Permission.contacts,
      Permission.sms,
      Permission.storage,
    ].request();

    final allGranted = statuses.values.every((status) => status.isGranted);

    if (allGranted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('permissions_granted', true);
    }

    return allGranted;
  }
}
