import 'package:agrobiometrik/domain/entities/embedding.dart';
import 'package:agrobiometrik/domain/entities/animal.dart';
import 'matching_service.dart';

class DatasetQualityService {
  final MatchingService matchingService;

  DatasetQualityService({required this.matchingService});

  /// Checks if an embedding is an outlier compared to its cluster (other embeddings of the same animal).
  /// Returns true if it deviates significantly from the centroid.
  bool isOutlier(Embedding newEmbedding, List<Embedding> cluster) {
    if (cluster.isEmpty) return false;

    List<double> centroid = List.filled(newEmbedding.vectorData.length, 0.0);
    for (var e in cluster) {
      for (int i = 0; i < e.vectorData.length; i++) {
        centroid[i] += e.vectorData[i];
      }
    }
    for (int i = 0; i < centroid.length; i++) {
      centroid[i] /= cluster.length;
    }

    double distance = matchingService.euclideanDistance(
      newEmbedding.vectorData,
      centroid,
    );

    const double outlierThreshold = 0.8;

    return distance > outlierThreshold;
  }

  /// Checks if the dataset is balanced across species.
  Map<String, double> checkBalance(List<Animal> animals) {
    Map<String, int> counts = {};
    for (var a in animals) {
      counts[a.species] = (counts[a.species] ?? 0) + 1;
    }

    Map<String, double> balance = {};
    int total = animals.length;
    if (total == 0) return {};

    counts.forEach((species, count) {
      balance[species] = count / total;
    });

    return balance;
  }
}
