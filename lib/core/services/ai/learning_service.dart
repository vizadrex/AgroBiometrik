import 'package:agrobiometrik/domain/entities/embedding.dart';
import 'package:agrobiometrik/domain/repositories/animal_repository.dart';
import 'dataset_quality_service.dart';

class LearningService {
  final AnimalRepository repository;
  final DatasetQualityService qualityService;

  LearningService({required this.repository, required this.qualityService});

  /// Processes a confirmed detection.
  /// This is "Active Learning" implicit feedback.
  Future<void> learnFromConfirmation(
    String animalId,
    List<double> newVector,
    String imagePath,
  ) async {
    final embedding = Embedding(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      animalId: animalId,
      vectorData: newVector,
      modelVersion: 'v1.0',
      normalizationMethod: 'L2',
      captureDate: DateTime.now(),
    );

    print('Learned new embedding for $animalId');
  }

  /// Exports dataset for external training.
  Future<void> exportDataset(String path) async {
    print('Exporting dataset to $path');
  }
}
