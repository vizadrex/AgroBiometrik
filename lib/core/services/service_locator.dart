import 'package:get_it/get_it.dart';
import '../../data/datasources/animal_local_data_source.dart';
import '../../data/datasources/database_helper.dart';
import '../../data/repositories/animal_repository_impl.dart';
import '../../domain/repositories/animal_repository.dart';
import 'ai/dataset_quality_service.dart';

import 'ai/embedding_service.dart';
import 'ai/identification_service.dart';
import 'ai/image_preprocessing_service.dart';

import 'ai/learning_service.dart';
import 'ai/matching_service.dart';

import 'ai/model_loader_service.dart';
import '../services/permission_service.dart';
import '../services/cleanup_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => ImagePreprocessingService());
  sl.registerLazySingleton(() => ModelLoaderService());
  sl.registerLazySingleton(() => MatchingService());

  sl.registerLazySingleton(
    () => EmbeddingService(preprocessingService: sl(), modelLoader: sl()),
  );
  sl.registerLazySingleton(
    () => IdentificationService(dataSource: sl(), matchingService: sl()),
  );

  sl.registerLazySingleton(() => DatasetQualityService(matchingService: sl()));
  sl.registerLazySingleton(
    () => LearningService(repository: sl(), qualityService: sl()),
  );

  sl.registerLazySingleton(() => PermissionService());
  sl.registerLazySingleton(
    () => DatabaseCleanupService(databaseHelper: DatabaseHelper()),
  );

  sl.registerLazySingleton<AnimalLocalDataSource>(
    () => AnimalLocalDataSourceImpl(databaseHelper: DatabaseHelper()),
  );
  sl.registerLazySingleton<AnimalRepository>(
    () => AnimalRepositoryImpl(localDataSource: sl()),
  );
}
