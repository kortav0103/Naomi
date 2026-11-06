import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/errors/exceptions.dart';

abstract class ReaderLocalDataSource {
  /// Lưu tiến trình đọc dở vào bảng reading_history của SQLite
  Future<void> saveProgress({
    required String chapterId,
    required int lastPageRead,
    required double readPercentage,
    bool isCompleted = false,
  });

  /// Đọc vị trí trang đọc dở gần nhất từ SQLite
  Future<int> getSavedProgress(String chapterId);
}

class ReaderLocalDataSourceImpl implements ReaderLocalDataSource {
  final DatabaseHelper dbHelper;

  ReaderLocalDataSourceImpl({required this.dbHelper});

  @override
  Future<void> saveProgress({
    required String chapterId,
    required int lastPageRead,
    required double readPercentage,
    bool isCompleted = false,
  }) async {
    try {
      final db = await dbHelper.database;
      final now = DateTime.now().toIso8601String();

      // Sử dụng ConflictAlgorithm.replace để cập nhật nếu đã có bản ghi cũ
      await db.insert(
        'reading_history',
        {
          'user_id': 'default_reader', // ID người dùng cục bộ mặc định
          'chapter_id': chapterId,
          'last_page_read': lastPageRead,
          'read_percentage': readPercentage,
          'is_completed': isCompleted ? 1 : 0,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException('Không thể lưu tiến trình đọc vào CSDL: $e');
    }
  }

  @override
  Future<int> getSavedProgress(String chapterId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> results = await db.query(
        'reading_history',
        columns: ['last_page_read'],
        where: 'chapter_id = ?',
        whereArgs: [chapterId],
      );

      if (results.isNotEmpty) {
        return results.first['last_page_read'] as int? ?? 1;
      }
      return 1; // Mặc định nếu chưa đọc thì bắt đầu từ trang 1
    } catch (e) {
      throw CacheException('Không thể nạp tiến trình đọc: $e');
    }
  }
}