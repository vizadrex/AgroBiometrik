import 'dart:typed_data';

import 'package:tflite_flutter/tflite_flutter.dart';
import 'image_preprocessing_service.dart';
import 'model_loader_service.dart';
import 'package:image/image.dart' as img;

class EmbeddingService {
  final ImagePreprocessingService preprocessingService;
  final ModelLoaderService modelLoader;

  Interpreter? _interpreter;
  final int inputSize = 224;
  final int outputSize = 1001;

  EmbeddingService({
    required this.preprocessingService,
    required this.modelLoader,
  });

  Future<void> loadModel(String modelPath) async {
    String path = modelPath;

    bool isValid = await modelLoader.verifyModelIntegrity(path);
    if (!isValid) {
      path = modelLoader.getFallbackModel();
    }

    try {
      _interpreter = await Interpreter.fromAsset(path);

      var outputShape = _interpreter!.getOutputTensor(0).shape;
      int actualSize = outputShape.last;

      if (!modelLoader.verifyEmbeddingSize(actualSize)) {
        throw Exception('Model output size mismatch');
      }

      print('Model loaded successfully: $path');
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  Future<List<double>> extractEmbedding(img.Image image) async {
    if (_interpreter == null) {
      return List.generate(outputSize, (index) => 0.0);
    }

    img.Image resized = preprocessingService.resizeImage(
      image,
      inputSize,
      inputSize,
    );

    Float32List input = preprocessingService.normalizeImage(resized);

    var inputTensor = input.reshape([1, inputSize, inputSize, 3]);

    var outputTensor = List.filled(
      1 * outputSize,
      0.0,
    ).reshape([1, outputSize]);

    _interpreter!.run(inputTensor, outputTensor);

    return List<double>.from(outputTensor[0]);
  }

  void close() {
    _interpreter?.close();
  }
}
