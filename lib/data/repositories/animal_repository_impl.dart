import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/animal.dart';
import '../../domain/repositories/animal_repository.dart';
import '../datasources/animal_local_data_source.dart';
import '../models/animal_model.dart';

class AnimalRepositoryImpl implements AnimalRepository {
  final AnimalLocalDataSource localDataSource;

  AnimalRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Animal>>> getAnimals() async {
    try {
      final animals = await localDataSource.getAnimals();
      return Right(animals);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getDatasetStats() async {
    try {
      final stats = await localDataSource.getDatasetStats();
      return Right(stats);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> registerAnimal(Animal animal) async {
    try {
      final animalModel = AnimalModel(
        id: animal.id,
        name: animal.name,
        species: animal.species,
        breed: animal.breed,
        registrationDate: animal.registrationDate,
        notes: animal.notes,
      );
      await localDataSource.cacheAnimal(animalModel);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAnimal(Animal animal) async {
    try {
      final animalModel = AnimalModel(
        id: animal.id,
        name: animal.name,
        species: animal.species,
        breed: animal.breed,
        registrationDate: animal.registrationDate,
        notes: animal.notes,
      );
      await localDataSource.updateAnimal(animalModel);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAnimal(String id) async {
    try {
      await localDataSource.deleteAnimal(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
