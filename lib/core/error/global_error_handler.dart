import 'package:flutter/foundation.dart';

class GlobalErrorHandler {
  static void onError(Object error, StackTrace stack) {
    if (kDebugMode) {
      print('Global Error Caught: $error');
      print(stack);
    }
  }

  static void onFlutterError(FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }
  }
}
