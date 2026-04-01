import 'package:agrobiometrik/data/datasources/animal_local_data_source.dart';
import 'package:agrobiometrik/data/models/embedding_model.dart';
import 'package:agrobiometrik/core/services/ai/matching_service.dart';

class IdentificationService {
  final AnimalLocalDataSource dataSource;
  final MatchingService matchingService;

  IdentificationService({
    required this.dataSource,
    required this.matchingService,
  });

  Future<String> predictSpecies(List<double> queryVector) async {
    try {
      final embeddings = await dataSource.getEmbeddings();
      if (embeddings.isEmpty) return 'Desconocida';

      final topMatches = _getTopMatches(queryVector, embeddings, 5);
      if (topMatches.isEmpty || topMatches.first['distance'] > 1.3) {
        return 'Desconocida';
      }

      return await _resolveMajoritySpecies(topMatches);
    } catch (_) {
      return 'Desconocida';
    }
  }

  Future<MatchResult> identifyAnimal(List<double> queryVector) async {
    try {
      final embeddings = await dataSource.getEmbeddings();
      if (embeddings.isEmpty) {
        return MatchResult(
          type: MatchType.newAnimal,
          distance: 1.0,
          confidence: 0.0,
        );
      }

      final bestMatch = _findBestMatch(queryVector, embeddings);
      if (bestMatch.embedding == null) {
        return MatchResult(
          type: MatchType.newAnimal,
          distance: 1.0,
          confidence: 0.0,
        );
      }

      final matchType = matchingService.determineMatchType(bestMatch.distance);
      final confidence = _calculateConfidence(bestMatch.distance);
      final candidateName = await _fetchCandidateName(
        bestMatch.embedding!.animalId,
      );

      return MatchResult(
        type: matchType,
        distance: bestMatch.distance,
        confidence: confidence,
        candidateId: bestMatch.embedding!.animalId,
        candidateName: candidateName,
      );
    } catch (_) {
      return MatchResult(
        type: MatchType.newAnimal,
        distance: 1.0,
        confidence: 0.0,
      );
    }
  }

  List<Map<String, dynamic>> _getTopMatches(
    List<double> queryVector,
    List<EmbeddingModel> embeddings,
    int limit,
  ) {
    final distances = <Map<String, dynamic>>[];
    for (final emb in embeddings) {
      if (emb.vector.length != queryVector.length) continue;
      final distance = matchingService.euclideanDistance(
        queryVector,
        emb.vector,
      );
      distances.add({'id': emb.animalId, 'distance': distance});
    }
    distances.sort(
      (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
    );
    return distances.take(limit).toList();
  }

  Future<String> _resolveMajoritySpecies(
    List<Map<String, dynamic>> topMatches,
  ) async {
    final animals = await dataSource.getAnimals();
    final speciesVotes = <String, int>{};

    for (final match in topMatches) {
      try {
        final animal = animals.firstWhere((a) => a.id == match['id']);
        final species = animal.species.trim();
        if (species.isNotEmpty) {
          speciesVotes[species] = (speciesVotes[species] ?? 0) + 1;
        }
      } catch (_) {}
    }

    if (speciesVotes.isEmpty) return 'Desconocida';

    String bestSpecies = 'Desconocida';
    int maxVotes = 0;
    speciesVotes.forEach((species, votes) {
      if (votes > maxVotes) {
        maxVotes = votes;
        bestSpecies = species;
      }
    });

    return bestSpecies;
  }

  ({EmbeddingModel? embedding, double distance}) _findBestMatch(
    List<double> queryVector,
    List<EmbeddingModel> embeddings,
  ) {
    double minDistance = double.infinity;
    EmbeddingModel? closestEmbedding;

    for (final embedding in embeddings) {
      if (embedding.vector.length != queryVector.length) continue;
      final distance = matchingService.euclideanDistance(
        queryVector,
        embedding.vector,
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestEmbedding = embedding;
      }
    }
    return (embedding: closestEmbedding, distance: minDistance);
  }

  double _calculateConfidence(double distance) {
    double confidence = (1.5 - distance) / 1.5;
    return confidence.clamp(0.0, 1.0);
  }

  Future<String?> _fetchCandidateName(String animalId) async {
    try {
      final animals = await dataSource.getAnimals();
      final animal = animals.firstWhere((a) => a.id == animalId);
      return animal.name;
    } catch (_) {
      return "Desconocido ($animalId)";
    }
  }
}
