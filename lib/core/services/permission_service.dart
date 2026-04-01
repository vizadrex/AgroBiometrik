import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Requests Camera and Storage permissions.
  /// Returns true if all critical permissions are granted.

  /// Requests Camera and Storage permissions.
  /// Returns true if all critical permissions are granted.
  Future<bool> requestCriticalPermissions() async {
    PermissionStatus cameraStatus = await Permission.camera.request();
    if (!cameraStatus.isGranted) return false;

    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      if (deviceInfo.version.sdkInt >= 33) {
        return true;
      }
    }

    PermissionStatus storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }

  /// Checks if camera permission is permanently denied.
  Future<bool> isCameraPermanentlyDenied() async {
    return await Permission.camera.isPermanentlyDenied;
  }

  /// Opens app settings.
  Future<void> openSettings() async {
    await openAppSettings();
  }
}
