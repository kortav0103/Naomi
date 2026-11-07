import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';

abstract class ReaderLocalDataSource {
  /// Lưu tiến trình đọc dở vào bảng reading_history của SQLite (FR-04, FR-08)
  Future<void> saveProgress({
    required String comicId,
    required String chapterId,
    required String comicTitle,
    String? coverUrl,
    required String chapterNumber,
    required int lastPageRead,
    required int totalPages,
    required double readPercentage,
    bool isCompleted = false,
  });

  /// Đọc vị trí trang đọc dở gần nhất từ SQLite
  Future<int> getSavedProgress(String chapterId);

  /// Lấy danh sách đường dẫn file ảnh offline của chương nếu đã tải về máy
  Future<List<String>?> getOfflinePages(String chapterId);
}

class ReaderLocalDataSourceImpl implements ReaderLocalDataSource {
  final DatabaseHelper dbHelper;
  final AuthLocalDataSource authLocalDataSource;

  /// Bộ nhớ đệm In-Memory dự phòng khi chạy trên Trình duyệt Web (kIsWeb)
  static final Map<String, int> webSavedProgress = {};

  ReaderLocalDataSourceImpl({
    required this.dbHelper,
    required this.authLocalDataSource,
  });

  Future<String> _getActiveUserId() async {
    try {
      final user = await authLocalDataSource.getCurrentUser();
      return user?.id ?? 'guest_default';
    } catch (_) {
      return 'guest_default';
    }
  }

  @override
  Future<void> saveProgress({
    required String comicId,
    required String chapterId,
    required String comicTitle,
    String? coverUrl,
    required String chapterNumber,
    required int lastPageRead,
    required int totalPages,
    required double readPercentage,
    bool isCompleted = false,
  }) async {
    if (kIsWeb) {
      webSavedProgress[chapterId] = lastPageRead;
      return;
    }

    try {
      final db = await dbHelper.database;
      final userId = await _getActiveUserId();
      final now = DateTime.now().toIso8601String();

      // Sử dụng ConflictAlgorithm.replace để cập nhật nếu đã có bản ghi cũ cho (user_id, comic_id)
      await db.insert(
        'reading_history',
        {
          'user_id': userId,
          'comic_id': comicId,
          'chapter_id': chapterId,
          'comic_title': comicTitle,
          'cover_url': coverUrl,
          'chapter_number': chapterNumber,
          'last_page_read': lastPageRead,
          'total_pages': totalPages,
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
    if (kIsWeb) {
      return webSavedProgress[chapterId] ?? 1;
    }

    try {
      final db = await dbHelper.database;
      final userId = await _getActiveUserId();
      final List<Map<String, dynamic>> results = await db.query(
        'reading_history',
        columns: ['last_page_read'],
        where: 'user_id = ? AND chapter_id = ?',
        whereArgs: [userId, chapterId],
      );

      if (results.isNotEmpty) {
        return results.first['last_page_read'] as int? ?? 1;
      }
      return 1; // Mặc định nếu chưa đọc thì bắt đầu từ trang 1
    } catch (e) {
      throw CacheException('Không thể nạp tiến trình đọc: $e');
    }
  }

  @override
  Future<List<String>?> getOfflinePages(String chapterId) async {
    if (kIsWeb) return null;

    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> results = await db.query(
        'pages',
        columns: ['file_path'],
        where: 'chapter_id = ? AND file_path IS NOT NULL',
        orderBy: 'page_number ASC',
      );

      if (results.isNotEmpty) {
        return results.map((r) => r['file_path'] as String).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
