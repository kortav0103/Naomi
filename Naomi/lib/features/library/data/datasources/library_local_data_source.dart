import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/entities/downloaded_chapter.dart';

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
}

class LibraryLocalDataSourceImpl implements LibraryLocalDataSource {
  final DatabaseHelper dbHelper;
  final Dio dio;
  static const String _defaultUserId = 'default_reader';

  LibraryLocalDataSourceImpl({
    required this.dbHelper,
    required this.dio,
  });

  @override
  Future<List<Bookmark>> getBookmarks() async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> results = await db.rawQuery('''
        SELECT b.comic_id, c.title, c.cover_url, c.author, b.created_at
        FROM bookmarks b
        JOIN comics c ON b.comic_id = c.id
        WHERE b.user_id = ?
        ORDER BY b.created_at DESC
      ''', [_defaultUserId]);

      return results.map((row) {
        return Bookmark(
          comicId: row['comic_id'] as String,
          title: row['title'] as String? ?? 'Untitled',
          coverUrl: row['cover_url'] as String?,
          author: row['author'] as String? ?? 'Unknown',
          addedAt: row['created_at'] as String? ?? '',
        );
      }).toList();
    } catch (e) {
      throw CacheException('Lỗi tải danh sách yêu thích: $e');
    }
  }

  @override
  Future<bool> isBookmarked(String comicId) async {
    try {
      final db = await dbHelper.database;
      final results = await db.query(
        'bookmarks',
        where: 'user_id = ? AND comic_id = ?',
        whereArgs: [_defaultUserId, comicId],
      );
      return results.isNotEmpty;
    } catch (e) {
      throw CacheException('Lỗi kiểm tra trạng thái yêu thích: $e');
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
      final exists = await isBookmarked(comicId);

      if (exists) {
        await db.delete(
          'bookmarks',
          where: 'user_id = ? AND comic_id = ?',
          whereArgs: [_defaultUserId, comicId],
        );
        return false; // Trạng thái mới: không còn bookmark
      } else {
        // Chưa yêu thích -> Lưu thông tin truyện vào bảng comics trước (đáp ứng ràng buộc khóa ngoại)
        await db.insert(
          'comics',
          {
            'id': comicId,
            'title': title,
            'cover_url': coverUrl,
            'author': author,
            'artist': author,
            'description': '',
            'status': 'ongoing',
            'content_rating': 'safe',
            'updated_at': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Sau đó thêm vào bảng bookmarks
        await db.insert(
          'bookmarks',
          {
            'user_id': _defaultUserId,
            'comic_id': comicId,
            'created_at': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        return true; // Trạng thái mới: đã bookmark
      }
    } catch (e) {
      throw CacheException('Lỗi cập nhật yêu thích: $e');
    }
  }

  @override
  Future<List<DownloadedChapter>> getDownloadedChapters() async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> results = await db.rawQuery('''
        SELECT d.chapter_id, d.local_directory, d.total_pages, d.created_at,
               COALESCE(c.title, 'Manga') as comic_title,
               COALESCE(ch.chapter_number, 1) as chapter_number
        FROM offline_downloads d
        LEFT JOIN chapters ch ON d.chapter_id = ch.id
        LEFT JOIN comics c ON ch.comic_id = c.id
        WHERE d.status = 'completed'
        ORDER BY d.created_at DESC
      ''');

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
      throw CacheException('Lỗi tải danh mục truyện ngoại tuyến: $e');
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

      // 3. Upsert vào bảng comics & chapters để thỏa mãn foreign key
      await db.insert(
        'comics',
        {
          'id': comicId,
          'title': comicTitle,
          'cover_url': coverUrl,
          'author': author,
          'artist': author,
          'description': '',
          'status': 'ongoing',
          'content_rating': 'safe',
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
          'translated_language': 'vi',
          'scanlation_group': 'MangaDex',
          'publish_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 4. Tải từng trang ảnh và lưu vào local directory + SQLite pages
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

      // 5. Cập nhật bảng offline_downloads trạng thái 'completed'
      await db.insert(
        'offline_downloads',
        {
          'chapter_id': chapterId,
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

      // Xóa file vật lý trong bộ nhớ
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

      // Xóa trong SQLite
      await db.delete(
        'pages',
        where: 'chapter_id = ?',
        whereArgs: [chapterId],
      );

      await db.delete(
        'offline_downloads',
        where: 'chapter_id = ?',
        whereArgs: [chapterId],
      );
    } catch (e) {
      throw CacheException('Lỗi xóa chương ngoại tuyến: $e');
    }
  }
}
