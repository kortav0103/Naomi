import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/entities/downloaded_chapter.dart';
import '../../domain/entities/reading_history_item.dart';

abstract class LibraryLocalDataSource {
  Future<List<Bookmark>> getBookmarks();
  Future<bool> toggleBookmark({
    required String comicId,
    required String title,
    String? coverUrl,
    required String author,
  });
  Future<bool> isBookmarked(String comicId);
  Future<List<DownloadedChapter>> getDownloadedChapters();
  Future<void> deleteDownloadedChapter(String chapterId);
  Future<bool> isChapterDownloaded(String chapterId);
  Future<void> downloadChapter({
    required String comicId,
    required String comicTitle,
    String? coverUrl,
    required String author,
    required String chapterId,
    required String chapterNumber,
    required String chapterTitle,
    void Function(int downloaded, int total)? onProgress,
  });
  Future<List<ReadingHistoryItem>> getReadingHistory();
  Future<ReadingHistoryItem?> getLastReadComic();
  Future<void> clearReadingHistory();
  Future<void> saveReadingProgress({
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
}

class LibraryLocalDataSourceImpl implements LibraryLocalDataSource {
  final DatabaseHelper dbHelper;
  final Dio dio;
  final AuthLocalDataSource authLocalDataSource;

  /// Bộ nhớ đệm In-Memory dự phòng khi chạy trên Trình duyệt Web (kIsWeb) vì Web không có SQLite FFI
  static final List<Bookmark> _webBookmarks = [];
  static final List<DownloadedChapter> _webDownloads = [];
  static final List<ReadingHistoryItem> _webHistory = [];

  LibraryLocalDataSourceImpl({
    required this.dbHelper,
    required this.dio,
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
  Future<List<Bookmark>> getBookmarks() async {
    if (kIsWeb) return List<Bookmark>.from(_webBookmarks);

    try {
      final db = await dbHelper.database;
      final userId = await _getActiveUserId();

      final List<Map<String, dynamic>> results = await db.query(
        'bookmarks',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      return results.map((row) {
        return Bookmark(
          comicId: row['comic_id'] as String,
          title: row['title'] as String? ?? 'Untitled Manga',
          coverUrl: row['cover_url'] as String?,
          author: row['author'] as String? ?? 'Unknown Author',
          addedAt: row['created_at'] as String? ?? '',
        );
      }).toList();
    } catch (e) {
      throw CacheException('Error loading favorites: $e');
    }
  }

  @override
  Future<bool> isBookmarked(String comicId) async {
    if (kIsWeb) return _webBookmarks.any((b) => b.comicId == comicId);

    try {
      final db = await dbHelper.database;
      final userId = await _getActiveUserId();

      final results = await db.query(
        'bookmarks',
        where: 'user_id = ? AND comic_id = ?',
        whereArgs: [userId, comicId],
      );
      return results.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> toggleBookmark({
    required String comicId,
    required String title,
    String? coverUrl,
    required String author,
  }) async {
    final now = DateTime.now().toIso8601String();
    if (kIsWeb) {
      final idx = _webBookmarks.indexWhere((b) => b.comicId == comicId);
      if (idx >= 0) {
        _webBookmarks.removeAt(idx);
        return false;
      } else {
        _webBookmarks.insert(
          0,
          Bookmark(
            comicId: comicId,
            title: title,
            coverUrl: coverUrl,
            author: author,
            addedAt: now,
          ),
        );
        return true;
      }
    }

    try {
      final db = await dbHelper.database;
      final userId = await _getActiveUserId();
      final exists = await isBookmarked(comicId);

      if (exists) {
        await db.delete(
          'bookmarks',
          where: 'user_id = ? AND comic_id = ?',
          whereArgs: [userId, comicId],
        );
        return false;
      } else {
        // Đồng bộ thực thể vào bảng comics chuẩn quan hệ 3NF
        await db.insert(
          'comics',
          {
            'id': comicId,
            'title': title,
            'author': author,
            'cover_url': coverUrl,
            'updated_at': now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        await db.insert(
          'bookmarks',
          {
            'user_id': userId,
            'comic_id': comicId,
            'title': title,
            'cover_url': coverUrl,
            'author': author,
            'created_at': now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        return true;
      }
    } catch (e) {
      throw CacheException('Error updating favorites: $e');
    }
  }

  @override
  Future<List<DownloadedChapter>> getDownloadedChapters() async {
    if (kIsWeb) return List<DownloadedChapter>.from(_webDownloads);

    try {
      final db = await dbHelper.database;
      final userId = await _getActiveUserId();
      final List<Map<String, dynamic>> results = await db.query(
        'offline_downloads',
        where: 'status = ? AND user_id = ?',
        whereArgs: ['completed', userId],
        orderBy: 'created_at DESC',
      );

      return results.map((row) {
        return DownloadedChapter(
          chapterId: row['chapter_id'] as String,
          comicTitle: row['comic_title'] as String? ?? 'Manga',
          chapterNumber: row['chapter_number']?.toString() ?? '1',
          localDirectory: row['local_directory'] as String? ?? '',
          totalPages: row['total_pages'] as int? ?? 0,
          downloadedAt: row['created_at'] as String? ?? '',
        );
      }).toList();
    } catch (e) {
      throw CacheException('Error loading offline chapters: $e');
    }
  }

  @override
  Future<bool> isChapterDownloaded(String chapterId) async {
    if (kIsWeb) return _webDownloads.any((d) => d.chapterId == chapterId);

    try {
      final db = await dbHelper.database;
      final userId = await _getActiveUserId();
      final results = await db.query(
        'offline_downloads',
        where: 'chapter_id = ? AND status = ? AND user_id = ?',
        whereArgs: [chapterId, 'completed', userId],
      );
      return results.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> downloadChapter({
    required String comicId,
    required String comicTitle,
    String? coverUrl,
    required String author,
    required String chapterId,
    required String chapterNumber,
    required String chapterTitle,
    void Function(int downloaded, int total)? onProgress,
  }) async {
    if (kIsWeb) {
      onProgress?.call(5, 10);
      await Future<void>.delayed(const Duration(milliseconds: 500));
      onProgress?.call(10, 10);
      _webDownloads.removeWhere((d) => d.chapterId == chapterId);
      _webDownloads.insert(
        0,
        DownloadedChapter(
          chapterId: chapterId,
          comicTitle: comicTitle,
          chapterNumber: chapterNumber,
          localDirectory: 'web_cache://$chapterId',
          totalPages: 10,
          downloadedAt: DateTime.now().toIso8601String(),
        ),
      );
      return;
    }

    Directory? chapterDir;
    try {
      // 1. Lấy danh sách link trang từ MangaDex At-Home server API
      final response = await dio.get('https://api.mangadex.org/at-home/server/$chapterId');
      final baseUrl = response.data['baseUrl'] as String;
      final chapterData = response.data['chapter'] as Map<String, dynamic>;
      final hash = chapterData['hash'] as String;
      final pageFiles = List<String>.from(chapterData['data'] as List);
      final totalPages = pageFiles.length;

      // 2. Tạo thư mục lưu trữ cục bộ trong App Documents
      final appDir = await getApplicationDocumentsDirectory();
      chapterDir = Directory('${appDir.path}/offline_chapters/$chapterId');
      if (!await chapterDir.exists()) {
        await chapterDir.create(recursive: true);
      }

      final db = await dbHelper.database;
      final userId = await _getActiveUserId();
      final now = DateTime.now().toIso8601String();

      // Đồng bộ metadata vào bảng comics & chapters chuẩn quan hệ 3NF
      await db.insert(
        'comics',
        {
          'id': comicId,
          'title': comicTitle,
          'author': author,
          'cover_url': coverUrl,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await db.insert(
        'chapters',
        {
          'id': chapterId,
          'comic_id': comicId,
          'chapter_number': double.tryParse(chapterNumber) ?? 1.0,
          'title': chapterTitle,
          'page_count': totalPages,
          'publish_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 3. Tải song song theo cụm 4 trang (Concurrent Batching) kèm báo cáo tiến độ thực (S11 / FR-06)
      int downloadedCount = 0;
      onProgress?.call(0, totalPages);

      const int batchSize = 4;
      for (int start = 0; start < totalPages; start += batchSize) {
        final end = (start + batchSize < totalPages) ? start + batchSize : totalPages;
        final List<Future<void>> batchFutures = [];

        for (int i = start; i < end; i++) {
          final pageIndex = i;
          final filename = pageFiles[pageIndex];
          final imageUrl = '$baseUrl/data/$hash/$filename';
          final localFilePath = '${chapterDir.path}/page_${pageIndex + 1}.jpg';

          batchFutures.add(() async {
            await dio.download(imageUrl, localFilePath);
            await db.insert(
              'pages',
              {
                'chapter_id': chapterId,
                'page_number': pageIndex + 1,
                'image_url': imageUrl,
                'file_path': localFilePath,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            downloadedCount++;
            onProgress?.call(downloadedCount, totalPages);
          }());
        }

        await Future.wait(batchFutures);
      }

      // 4. Lưu bản ghi offline_downloads hoàn tất
      await db.insert(
        'offline_downloads',
        {
          'user_id': userId,
          'chapter_id': chapterId,
          'comic_id': comicId,
          'comic_title': comicTitle,
          'chapter_number': chapterNumber,
          'status': 'completed',
          'downloaded_pages': totalPages,
          'total_pages': totalPages,
          'local_directory': chapterDir.path,
          'created_at': now,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      // Dọn dẹp thư mục dở dang nếu tải thất bại giữa chừng (Atomic Rollback)
      if (chapterDir != null && await chapterDir.exists()) {
        try {
          await chapterDir.delete(recursive: true);
        } catch (_) {}
      }
      throw CacheException('Unable to download chapter to device: $e');
    }
  }

  @override
  Future<void> deleteDownloadedChapter(String chapterId) async {
    if (kIsWeb) {
      _webDownloads.removeWhere((d) => d.chapterId == chapterId);
      return;
    }

    try {
      final db = await dbHelper.database;
      final userId = await _getActiveUserId();

      final results = await db.query(
        'offline_downloads',
        columns: ['local_directory'],
        where: 'chapter_id = ? AND user_id = ?',
        whereArgs: [chapterId, userId],
      );

      if (results.isNotEmpty) {
        final dirPath = results.first['local_directory'] as String?;
        if (dirPath != null && dirPath.isNotEmpty) {
          final dir = Directory(dirPath);
          if (await dir.exists()) {
            await dir.delete(recursive: true);
          }
        }
      }

      await db.delete('pages', where: 'chapter_id = ?', whereArgs: [chapterId]);
      await db.delete('chapters', where: 'id = ?', whereArgs: [chapterId]);
      await db.delete('offline_downloads', where: 'chapter_id = ? AND user_id = ?', whereArgs: [chapterId, userId]);
    } catch (e) {
      throw CacheException('Error deleting offline chapter: $e');
    }
  }

  @override
  Future<List<ReadingHistoryItem>> getReadingHistory() async {
    if (kIsWeb) return List<ReadingHistoryItem>.from(_webHistory);

    try {
      final db = await dbHelper.database;
      final userId = await _getActiveUserId();

      final List<Map<String, dynamic>> results = await db.query(
        'reading_history',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'updated_at DESC',
      );

      return results.map((row) {
        return ReadingHistoryItem(
          comicId: row['comic_id'] as String,
          chapterId: row['chapter_id'] as String,
          comicTitle: row['comic_title'] as String? ?? 'Manga',
          coverUrl: row['cover_url'] as String?,
          chapterNumber: row['chapter_number']?.toString() ?? '1',
          lastPageRead: row['last_page_read'] as int? ?? 1,
          totalPages: row['total_pages'] as int? ?? 1,
          readPercentage: (row['read_percentage'] as num?)?.toDouble() ?? 0.0,
          isCompleted: (row['is_completed'] as int?) == 1,
          updatedAt: row['updated_at'] as String? ?? '',
        );
      }).toList();
    } catch (e) {
      throw CacheException('Error loading reading history: $e');
    }
  }

  @override
  Future<ReadingHistoryItem?> getLastReadComic() async {
    if (kIsWeb) return _webHistory.isNotEmpty ? _webHistory.first : null;

    try {
      final db = await dbHelper.database;
      final userId = await _getActiveUserId();

      final List<Map<String, dynamic>> results = await db.query(
        'reading_history',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'updated_at DESC',
        limit: 1,
      );

      if (results.isNotEmpty) {
        final row = results.first;
        return ReadingHistoryItem(
          comicId: row['comic_id'] as String,
          chapterId: row['chapter_id'] as String,
          comicTitle: row['comic_title'] as String? ?? 'Manga',
          coverUrl: row['cover_url'] as String?,
          chapterNumber: row['chapter_number']?.toString() ?? '1',
          lastPageRead: row['last_page_read'] as int? ?? 1,
          totalPages: row['total_pages'] as int? ?? 1,
          readPercentage: (row['read_percentage'] as num?)?.toDouble() ?? 0.0,
          isCompleted: (row['is_completed'] as int?) == 1,
          updatedAt: row['updated_at'] as String? ?? '',
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearReadingHistory() async {
    if (kIsWeb) {
      _webHistory.clear();
      return;
    }

    try {
      final db = await dbHelper.database;
      final userId = await _getActiveUserId();
      await db.delete('reading_history', where: 'user_id = ?', whereArgs: [userId]);
    } catch (e) {
      throw CacheException('Unable to clear reading history: $e');
    }
  }

  @override
  Future<void> saveReadingProgress({
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
    final now = DateTime.now().toIso8601String();
    if (kIsWeb) {
      _webHistory.removeWhere((h) => h.comicId == comicId);
      _webHistory.insert(
        0,
        ReadingHistoryItem(
          comicId: comicId,
          chapterId: chapterId,
          comicTitle: comicTitle,
          coverUrl: coverUrl,
          chapterNumber: chapterNumber,
          lastPageRead: lastPageRead,
          totalPages: totalPages,
          readPercentage: readPercentage,
          isCompleted: isCompleted,
          updatedAt: now,
        ),
      );
      return;
    }

    try {
      final db = await dbHelper.database;
      final userId = await _getActiveUserId();

      // 1. Đồng bộ thông tin bộ truyện vào bảng comics
      await db.insert(
        'comics',
        {
          'id': comicId,
          'title': comicTitle,
          'cover_url': coverUrl,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Ghi nhận / Cập nhật tiến độ đọc dở
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

      // 3. Tự động dọn dẹp lịch sử: Giới hạn tối đa 100 bộ truyện đọc gần nhất cho mỗi tài khoản (Retention Policy)
      await db.execute('''
        DELETE FROM reading_history
        WHERE user_id = ? AND id NOT IN (
          SELECT id FROM reading_history
          WHERE user_id = ?
          ORDER BY updated_at DESC
          LIMIT 100
        )
      ''', [userId, userId]);
    } catch (e) {
      throw CacheException('Unable to save reading progress: $e');
    }
  }
}
