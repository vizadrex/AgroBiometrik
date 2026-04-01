import 'package:equatable/equatable.dart';

class Embedding extends Equatable {
  final String id;
  final String animalId;
  final List<double> vectorData;
  final String modelVersion;
  final String normalizationMethod;
  final DateTime captureDate;

  const Embedding({
    required this.id,
    required this.animalId,
    required this.vectorData,
    required this.modelVersion,
    required this.normalizationMethod,
    required this.captureDate,
  });

  @override
  List<Object?> get props => [
    id,
    animalId,
    vectorData,
    modelVersion,
    normalizationMethod,
    captureDate,
  ];
}
