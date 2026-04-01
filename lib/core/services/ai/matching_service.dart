import 'dart:math';

class MatchingService {
  static const double thresholdMatch = 0.55;
  static const double thresholdPossible = 0.75;

  /// Calculates Euclidean Distance between two vectors.
  double euclideanDistance(List<double> v1, List<double> v2) {
    if (v1.length != v2.length) {
      throw Exception('Vector lengths do not match');
    }

    double sum = 0;
    for (int i = 0; i < v1.length; i++) {
      sum += pow(v1[i] - v2[i], 2);
    }
    return sqrt(sum);
  }

  /// Calculates Cosine Similarity between two vectors.
  double cosineSimilarity(List<double> v1, List<double> v2) {
    if (v1.length != v2.length) {
      throw Exception('Vector lengths do not match');
    }

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < v1.length; i++) {
      dotProduct += v1[i] * v2[i];
      normA += pow(v1[i], 2);
      normB += pow(v2[i], 2);
    }

    if (normA == 0.0 || normB == 0.0) {
      return 0.0;
    }

    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  MatchType determineMatchType(double distance) {
    if (distance < thresholdMatch) return MatchType.match;
    if (distance < thresholdPossible) return MatchType.possible;
    return MatchType.newAnimal;
  }
}

enum MatchType { match, possible, newAnimal }

class MatchResult {
  final MatchType type;
  final double distance;
  final double confidence;
  final String? candidateId;
  final String? candidateName;

  MatchResult({
    required this.type,
    required this.distance,
    required this.confidence,
    this.candidateId,
    this.candidateName,
  });
}
