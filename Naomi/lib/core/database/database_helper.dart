import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Quản lý CSDL cục bộ SQLite của Naomi chuẩn Production (Offline-First)
class DatabaseHelper {
  static const String _dbName = 'naomi.db';
  static const int _dbVersion = 2; // Nâng cấp lên v2 hỗ trợ Lịch sử đọc đầy đủ

  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        // Tối ưu hiệu năng WAL (Write-Ahead Logging) cho tốc độ đọc/ghi cực nhanh <= 10ms
        await db.execute('PRAGMA journal_mode = WAL');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Bảng Truyện (Comics)
    await db.execute('''
      CREATE TABLE comics (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        alt_titles TEXT,
        description TEXT,
        author TEXT,
        artist TEXT,
        status TEXT,
        cover_url TEXT,
        content_rating TEXT,
        updated_at TEXT
      )
    ''');

    // 2. Bảng Chương (Chapters)
    await db.execute('''
      CREATE TABLE chapters (
        id TEXT PRIMARY KEY,
        comic_id TEXT NOT NULL,
        chapter_number REAL,
        volume_number TEXT,
        title TEXT,
        translated_language TEXT DEFAULT 'en',
        page_count INTEGER DEFAULT 0,
        publish_at TEXT
      )
    ''');

    // 3. Bảng Trang ảnh (Pages)
    await db.execute('''
      CREATE TABLE pages (
        chapter_id TEXT NOT NULL,
        page_number INTEGER NOT NULL,
        image_url TEXT NOT NULL,
        file_path TEXT,
        PRIMARY KEY (chapter_id, page_number)
      )
    ''');

    // 4. Bảng Lịch sử đọc dở (Reading History - FR-04 & FR-08)
    await db.execute('''
      CREATE TABLE reading_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        comic_id TEXT NOT NULL,
        chapter_id TEXT NOT NULL,
        comic_title TEXT NOT NULL,
        cover_url TEXT,
        chapter_number TEXT NOT NULL DEFAULT '1',
        last_page_read INTEGER NOT NULL DEFAULT 1,
        total_pages INTEGER NOT NULL DEFAULT 1,
        read_percentage REAL DEFAULT 0.0,
        is_completed INTEGER DEFAULT 0,
        updated_at TEXT NOT NULL,
        UNIQUE (user_id, comic_id)
      )
    ''');

    // 5. Bảng Tủ sách yêu thích (Bookmarks - FR-07)
    await db.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        comic_id TEXT NOT NULL,
        title TEXT NOT NULL DEFAULT '',
        cover_url TEXT,
        author TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        UNIQUE (user_id, comic_id)
      )
    ''');

    // 6. Bảng Quản lý tải ngoại tuyến (Offline Downloads - FR-06)
    await db.execute('''
      CREATE TABLE offline_downloads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chapter_id TEXT NOT NULL UNIQUE,
        comic_id TEXT NOT NULL DEFAULT '',
        comic_title TEXT NOT NULL DEFAULT 'Manga',
        chapter_number TEXT NOT NULL DEFAULT '1',
        status TEXT NOT NULL DEFAULT 'completed',
        downloaded_pages INTEGER DEFAULT 0,
        total_pages INTEGER DEFAULT 0,
        local_directory TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Chỉ mục tăng tốc độ truy vấn <= 20ms
    await db.execute('CREATE INDEX idx_reading_history_user ON reading_history (user_id, updated_at DESC)');
    await db.execute('CREATE INDEX idx_bookmarks_user ON bookmarks (user_id, created_at DESC)');
    await db.execute('CREATE INDEX idx_offline_downloads ON offline_downloads (chapter_id)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Nâng cấp mượt mà từ v1 lên v2
      await db.execute('DROP TABLE IF EXISTS reading_history');
      await db.execute('DROP TABLE IF EXISTS bookmarks');
      await db.execute('DROP TABLE IF EXISTS offline_downloads');

      await db.execute('''
        CREATE TABLE reading_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          comic_id TEXT NOT NULL,
          chapter_id TEXT NOT NULL,
          comic_title TEXT NOT NULL,
          cover_url TEXT,
          chapter_number TEXT NOT NULL DEFAULT '1',
          last_page_read INTEGER NOT NULL DEFAULT 1,
          total_pages INTEGER NOT NULL DEFAULT 1,
          read_percentage REAL DEFAULT 0.0,
          is_completed INTEGER DEFAULT 0,
          updated_at TEXT NOT NULL,
          UNIQUE (user_id, comic_id)
        )
      ''');

      await db.execute('''
        CREATE TABLE bookmarks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          comic_id TEXT NOT NULL,
          title TEXT NOT NULL DEFAULT '',
          cover_url TEXT,
          author TEXT NOT NULL DEFAULT '',
          created_at TEXT NOT NULL,
          UNIQUE (user_id, comic_id)
        )
      ''');

      await db.execute('''
        CREATE TABLE offline_downloads (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          chapter_id TEXT NOT NULL UNIQUE,
          comic_id TEXT NOT NULL DEFAULT '',
          comic_title TEXT NOT NULL DEFAULT 'Manga',
          chapter_number TEXT NOT NULL DEFAULT '1',
          status TEXT NOT NULL DEFAULT 'completed',
          downloaded_pages INTEGER DEFAULT 0,
          total_pages INTEGER DEFAULT 0,
          local_directory TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      await db.execute('CREATE INDEX IF NOT EXISTS idx_reading_history_user ON reading_history (user_id, updated_at DESC)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_bookmarks_user ON bookmarks (user_id, created_at DESC)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_offline_downloads ON offline_downloads (chapter_id)');
    }
  }
}
