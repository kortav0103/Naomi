import 'dart:io';
import 'package:dio/dio.dart';
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
          author: row['author'] as String? ?? 'Tác giả chưa cập nhật',
          addedAt: row['created_at'] as String? ?? '',
        );
      }).toList();
    } catch (e) {
      throw CacheException('Lỗi nạp danh sách truyện yêu thích: $e');
    }
  }

  @override
  Future<bool> isBookmarked(String comicId) async {
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
        await db.insert(
          'bookmarks',
          {
            'user_id': userId,
            'comic_id': comicId,
            'title': title,
            'cover_url': coverUrl,
            'author': author,
            'created_at': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        return true;
      }
    } catch (e) {
      throw CacheException('Lỗi cập nhật yêu thích: $e');
    }
  }

  @override
  Future<List<DownloadedChapter>> getDownloadedChapters() async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> results = await db.query(
        'offline_downloads',
        where: 'status = ?',
        whereArgs: ['completed'],
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
      throw CacheException('Lỗi nạp danh sách truyện ngoại tuyến: $e');
    }
  }

  @override
  Future<bool> isChapterDownloaded(String chapterId) async {
    try {
      final db = await dbHelper.database;
      final results = await db.query(
        'offline_downloads',
        where: 'chapter_id = ? AND status = ?',
        whereArgs: [chapterId, 'completed'],
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
  }) async {
    try {
      // 1. Lấy danh sách link trang từ MangaDex At-Home server API
      final response = await dio.get('https://api.mangadex.org/at-home/server/$chapterId');
      final baseUrl = response.data['baseUrl'] as String;
      final chapterData = response.data['chapter'] as Map<String, dynamic>;
      final hash = chapterData['hash'] as String;
      final pageFiles = List<String>.from(chapterData['data'] as List);

      // 2. Tạo thư mục lưu trữ cục bộ trong App Documents
      final appDir = await getApplicationDocumentsDirectory();
      final chapterDir = Directory('${appDir.path}/offline_chapters/$chapterId');
      if (!await chapterDir.exists()) {
        await chapterDir.create(recursive: true);
      }

      final db = await dbHelper.database;
      final now = DateTime.now().toIso8601String();

      // 3. Tải từng trang ảnh và lưu vào local directory + SQLite pages
      for (int i = 0; i < pageFiles.length; i++) {
        final filename = pageFiles[i];
        final imageUrl = '$baseUrl/data/$hash/$filename';
        final localFilePath = '${chapterDir.path}/page_${i + 1}.jpg';

        await dio.download(imageUrl, localFilePath);

        await db.insert(
          'pages',
          {
            'chapter_id': chapterId,
            'page_number': i + 1,
            'image_url': imageUrl,
            'file_path': localFilePath,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // 4. Lưu bản ghi offline_downloads độc lập không phụ thuộc bảng cha
      await db.insert(
        'offline_downloads',
        {
          'chapter_id': chapterId,
          'comic_id': comicId,
          'comic_title': comicTitle,
          'chapter_number': chapterNumber,
          'status': 'completed',
          'downloaded_pages': pageFiles.length,
          'total_pages': pageFiles.length,
          'local_directory': chapterDir.path,
          'created_at': now,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException('Không thể tải chương truyện về thiết bị: $e');
    }
  }

  @override
  Future<void> deleteDownloadedChapter(String chapterId) async {
    try {
      final db = await dbHelper.database;

      final results = await db.query(
        'offline_downloads',
        columns: ['local_directory'],
        where: 'chapter_id = ?',
        whereArgs: [chapterId],
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
      await db.delete('offline_downloads', where: 'chapter_id = ?', whereArgs: [chapterId]);
    } catch (e) {
      throw CacheException('Lỗi xóa chương ngoại tuyến: $e');
    }
  }

  @override
  Future<List<ReadingHistoryItem>> getReadingHistory() async {
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
      throw CacheException('Lỗi nạp lịch sử đọc dở: $e');
    }
  }

  @override
  Future<ReadingHistoryItem?> getLastReadComic() async {
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
    try {
      final db = await dbHelper.database;
      final userId = await _getActiveUserId();
      await db.delete('reading_history', where: 'user_id = ?', whereArgs: [userId]);
    } catch (e) {
      throw CacheException('Không thể xóa lịch sử đọc: $e');
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
    try {
      final db = await dbHelper.database;
      final userId = await _getActiveUserId();
      final now = DateTime.now().toIso8601String();

      // Lưu trữ độc lập, giải quyết dứt điểm lỗi Foreign Key khi đọc Online
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
      throw CacheException('Không thể lưu tiến trình đọc: $e');
    }
  }
}
