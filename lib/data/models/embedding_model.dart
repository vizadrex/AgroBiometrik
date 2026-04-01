import 'dart:convert';
import 'dart:typed_data';

class EmbeddingModel {
  final String id;
  final String animalId;
  final List<double> vector;
  final String modelVersion;

  EmbeddingModel({
    required this.id,
    required this.animalId,
    required this.vector,
    required this.modelVersion,
  });

  factory EmbeddingModel.fromMap(Map<String, dynamic> map) {
    return EmbeddingModel(
      id: map['id'],
      animalId: map['animal_id'],
      vector: _parseVector(map['vector_data']),
      modelVersion: map['model_version'] ?? 'unknown',
    );
  }

  static List<double> _parseVector(dynamic blob) {
    if (blob is Uint8List) {
      try {
        final str = utf8.decode(blob);
        final List<dynamic> list = jsonDecode(str);
        return list.cast<double>();
      } catch (e) {
        return [];
      }
    } else if (blob is String) {
      final List<dynamic> list = jsonDecode(blob);
      return list.cast<double>();
    }
    return [];
  }
}
