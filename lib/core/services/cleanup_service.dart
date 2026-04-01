import '../services/ai/dataset_quality_service.dart';
import '../../data/datasources/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseCleanupService {
  final DatabaseHelper databaseHelper;

  DatabaseCleanupService({required this.databaseHelper});

  /// Runs daily maintenance tasks.
  Future<void> runMaintenance() async {
    await _removeRedundantEmbeddings();
    await _compressOldCaptures();
    await _limitCaptureHistory();
  }

  /// Removes embeddings that are marked as outliers or too similar (if policy allows).
  Future<void> _removeRedundantEmbeddings() async {
    final db = await databaseHelper.database;

    int deleted = await db.delete(
      'embeddings',
      where: 'is_outlier = ?',
      whereArgs: [1],
    );

    if (deleted > 0) {
      print('Cleanup: Removed $deleted outlier embeddings.');
    }
  }

  /// Deletes old capture logs to save space, keeping only last N days/items.
  Future<void> _limitCaptureHistory() async {
    final db = await databaseHelper.database;

    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM captures'),
    );
    if (count != null && count > 1000) {
      await db.execute('''
        DELETE FROM captures WHERE id IN (
          SELECT id FROM captures ORDER BY timestamp ASC LIMIT ${count - 1000}
        )
      ''');
      print('Cleanup: Pruned old captures.');
    }
  }

  Future<void> _compressOldCaptures() async {}
}
