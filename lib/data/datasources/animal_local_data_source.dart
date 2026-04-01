import 'package:sqflite/sqflite.dart';
import '../datasources/database_helper.dart';
import '../models/animal_model.dart';
import '../../core/error/failures.dart';

import 'dart:convert';
import '../models/embedding_model.dart';

abstract class AnimalLocalDataSource {
  Future<List<AnimalModel>> getAnimals();
  Future<void> cacheAnimal(AnimalModel animal);

  Future<List<EmbeddingModel>> getEmbeddings();
  Future<void> cacheEmbedding(EmbeddingModel embedding);
  Future<Map<String, int>> getDatasetStats();
  Future<void> updateAnimal(AnimalModel animal);
  Future<void> deleteAnimal(String id);
}

class AnimalLocalDataSourceImpl implements AnimalLocalDataSource {
  final DatabaseHelper databaseHelper;

  AnimalLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<Map<String, int>> getDatasetStats() async {
    final db = await databaseHelper.database;
    final totalAnimals =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM animals'),
        ) ??
        0;
    final totalEmbeddings =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM embeddings'),
        ) ??
        0;

    final wellIdentified =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM (SELECT animal_id FROM embeddings GROUP BY animal_id HAVING COUNT(*) >= 3)',
          ),
        ) ??
        0;

    return {
      'totalAnimals': totalAnimals,
      'totalEmbeddings': totalEmbeddings,
      'wellIdentified': wellIdentified,
      'weakIdentified': totalAnimals - wellIdentified,
    };
  }

  @override
  Future<List<AnimalModel>> getAnimals() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('animals');
    return List.generate(maps.length, (i) => AnimalModel.fromJson(maps[i]));
  }

  @override
  Future<void> updateAnimal(AnimalModel animal) async {
    final db = await databaseHelper.database;
    await db.update(
      'animals',
      animal.toJson(),
      where: 'id = ?',
      whereArgs: [animal.id],
    );
  }

  @override
  Future<void> deleteAnimal(String id) async {
    final db = await databaseHelper.database;
    await db.delete('embeddings', where: 'animal_id = ?', whereArgs: [id]);
    await db.delete('animals', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> cacheAnimal(AnimalModel animal) async {
    final db = await databaseHelper.database;
    await db.insert(
      'animals',
      animal.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<EmbeddingModel>> getEmbeddings() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('embeddings');
    return List.generate(maps.length, (i) => EmbeddingModel.fromMap(maps[i]));
  }

  @override
  Future<void> cacheEmbedding(EmbeddingModel embedding) async {
    final db = await databaseHelper.database;
    final vectorJson = jsonEncode(embedding.vector);

    await db.insert('embeddings', {
      'id': embedding.id,
      'animal_id': embedding.animalId,
      'vector_data': vectorJson,
      'model_version': embedding.modelVersion,
      'capture_date': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
