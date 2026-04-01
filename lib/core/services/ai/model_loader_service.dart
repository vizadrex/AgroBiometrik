import 'dart:io';
import 'package:flutter/services.dart';

class ModelLoaderService {
  static const String defaultModelPath = 'assets/models/mobilenet_v2.tflite';
  static const int expectedEmbeddingSize = 1001;

  /// Verifies if the model exists and has correct integrity (size check).
  Future<bool> verifyModelIntegrity(String path) async {
    try {
      final ByteData data = await rootBundle.load(path);
      if (data.lengthInBytes == 0) {
        print('Error: Model file is empty.');
        return false;
      }

      print('Model Integrity Verified: $path (${data.lengthInBytes} bytes)');
      return true;
    } catch (e) {
      print('Error verifying model integrity: $e');
      return false;
    }
  }

  /// Verifies if the model's output shape matches expected DB schema.
  /// (This usually requires loading the model and checking output tensor).
  bool verifyEmbeddingSize(int actualSize) {
    if (actualSize != expectedEmbeddingSize) {
      print(
        'CRITICAL: Model embedding size $actualSize does not match DB schema $expectedEmbeddingSize.',
      );
      return false;
    }
    return true;
  }

  /// Returns the path to a safe fallback model if the primary fails.
  String getFallbackModel() {
    print('WARNING: Switching to fallback/default model.');
    return defaultModelPath;
  }
}
