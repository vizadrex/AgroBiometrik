import 'package:image/image.dart' as img;
import 'dart:typed_data';

class ImagePreprocessingService {
  /// Sizes the image to the model input size (e.g., 224x224).
  img.Image resizeImage(img.Image image, int targetWidth, int targetHeight) {
    return img.copyResize(image, width: targetWidth, height: targetHeight);
  }

  /// Normalizes the pixel values to [-1, 1] or [0, 1] depending on model requirements.
  /// For this example, we assume models expect Float32 inputs normalized to [0, 1].
  Float32List normalizeImage(img.Image image) {
    var convertedBytes = Float32List(1 * image.height * image.width * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < image.height; i++) {
      for (var j = 0; j < image.width; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = pixel.r / 255.0;
        buffer[pixelIndex++] = pixel.g / 255.0;
        buffer[pixelIndex++] = pixel.b / 255.0;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }
}
