import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class GetPermissions {
  GetPermissions();
  static Future<bool> getLocationPermissions() async {
    Permission locationPermission = Permission.location;
    return await locationPermission.request().then((value) async {
      if (value.isGranted) {
        if (kDebugMode) {
          print('Location Permission granted');
        }
        return true;
      } else if (value.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      } else {
        if (kDebugMode) {
          print('Location Permission denied');
        }
        return false;
      }
    });
  }

  Future<void> getCameraPermissions() async {
    Permission cameraPermission = Permission.camera;
    await cameraPermission.request().then((value) {
      if (value.isGranted) {
        if (kDebugMode) {
          print('Camera Permission granted');
        }
      } else {
        if (kDebugMode) {
          print('Camera Permission denied');
        }
      }
    });
  }

  Future<bool> getPhotoPermissions() async {
    Permission photoPermission = Permission.photos;
    return await photoPermission.request().then((value) {
      if (value.isGranted) {
        if (kDebugMode) {
          print('Photo Permission granted');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('Photo Permission denied');
        }
        return false;
      }
    });
  }

  Future<void> getStoragePermissions() async {
    Permission storagePermission = Permission.storage;
    await storagePermission.request().then((value) {
      if (value.isGranted) {
        if (kDebugMode) {
          print('Permission granted');
        }
      } else {
        if (kDebugMode) {
          print('Permission denied');
        }
      }
    });
  }

  static Future<bool> getRecordPermission() async {
    Permission recordPermission = Permission.microphone;
    return await recordPermission.request().then((value) {
      if (value.isGranted) {
        if (kDebugMode) {
          print('Record Permission granted');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('Record Permission denied');
        }
        return false;
      }
    });
  }
}
