import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Quản lý CSDL cục bộ SQLite của Naomi theo đúng chuẩn Mục 1.5
class DatabaseHelper {
  static const String _dbName = 'naomi.db';
  static const int _dbVersion = 1;

  // Singleton pattern đảm bảo toàn bộ app chỉ dùng 1 kết nối duy nhất
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
      onConfigure: (db) async {
        // Bật tính năng ràng buộc khóa ngoại (Foreign Keys)
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  /// Khởi tạo 6 bảng dữ liệu cục bộ chuẩn 3NF/BCNF
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
        publish_at TEXT,
        FOREIGN KEY (comic_id) REFERENCES comics (id) ON DELETE CASCADE
      )
    ''');

    // 3. Bảng Trang ảnh (Pages)
    await db.execute('''
      CREATE TABLE pages (
        chapter_id TEXT NOT NULL,
        page_number INTEGER NOT NULL,
        image_url TEXT NOT NULL,
        file_path TEXT,
        PRIMARY KEY (chapter_id, page_number),
        FOREIGN KEY (chapter_id) REFERENCES chapters (id) ON DELETE CASCADE
      )
    ''');

    // 4. Bảng Lịch sử đọc dở (Reading History - FR-04)
    await db.execute('''
      CREATE TABLE reading_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        chapter_id TEXT NOT NULL,
        last_page_read INTEGER NOT NULL DEFAULT 1,
        read_percentage REAL DEFAULT 0.0,
        is_completed INTEGER DEFAULT 0,
        updated_at TEXT NOT NULL,
        UNIQUE (user_id, chapter_id),
        FOREIGN KEY (chapter_id) REFERENCES chapters (id) ON DELETE CASCADE
      )
    ''');

    // 5. Bảng Tủ sách yêu thích (Bookmarks - FR-07)
    await db.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        comic_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        UNIQUE (user_id, comic_id),
        FOREIGN KEY (comic_id) REFERENCES comics (id) ON DELETE CASCADE
      )
    ''');

    // 6. Bảng Quản lý tải ngoại tuyến (Offline Downloads - FR-06)
    await db.execute('''
      CREATE TABLE offline_downloads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chapter_id TEXT NOT NULL UNIQUE,
        status TEXT NOT NULL DEFAULT 'pending',
        downloaded_pages INTEGER DEFAULT 0,
        total_pages INTEGER DEFAULT 0,
        local_directory TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (chapter_id) REFERENCES chapters (id) ON DELETE CASCADE
      )
    ''');

    // Thiết lập Indexes tăng tốc độ truy vấn <= 50ms theo NFR-09
    await db.execute('CREATE INDEX idx_chapters_comic_id ON chapters (comic_id)');
    await db.execute('CREATE INDEX idx_reading_history_lookup ON reading_history (user_id, chapter_id)');
    await db.execute('CREATE INDEX idx_bookmarks_lookup ON bookmarks (user_id, comic_id)');
    await db.execute('CREATE INDEX idx_offline_downloads_chapter ON offline_downloads (chapter_id)');
  }
}