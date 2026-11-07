# NAOMI — Ambient Manga Reader & Tracker

> **Đồ án môn học:** Phát triển Ứng dụng Di động (Mobile Development Course Project)  
> **Trường:** Đại học Bách Khoa - ĐHQG TP.HCM (HCMUT - VNU-HCM)  
> **Giảng viên hướng dẫn:** TS. Phan Trần Minh Khuê  
> **Sinh viên thực hiện:** Duong Dang Khoa — MSSV: 2352551  
> **Phiên bản:** `v1.1.0-commercial-ready` (Assignment 02 Implementation & Full Audit Upgrade)

---

## 1. Giới thiệu tổng quan (Overview)

**Naomi** là ứng dụng đọc và theo dõi truyện tranh di động được thiết kế theo triết lý **Tối giản (Minimalism) & Đắm chìm (Ambient Reading)**:
- **Tối ưu trải nghiệm đọc (FR-02, FR-03, FR-13):** Hỗ trợ linh hoạt cả 2 chế độ đọc: **Webtoon (Cuộn dọc liên tục với `cacheExtent: 2500`, `InteractiveViewer` bọc ngoài chống xung đột cử chỉ và tự động theo dõi trang theo vị trí cuộn)** và **Manga (Lật ngang từng trang với Zoom đa điểm)**. Hỗ trợ phân trang tuần hoàn (Loop Pagination) tải tối đa **2.500 chương/bộ truyện** kèm bộ lọc khử trùng lặp chương thông minh (ưu tiên bản dịch Tiếng Việt `vi` so với Tiếng Anh `en`).
- **Chế độ đọc tập trung (Focus Mode - FR-02):** Tự động ẩn toàn bộ thanh công cụ, thanh trạng thái hệ thống để trả lại 100% không gian hiển thị cho từng khung tranh.
- **Không gian âm thanh thư giãn thông minh (Ambient Soundscapes - FR-05):** Tích hợp trình phát nhạc nền không lời (`just_audio` + `audio_session`) với tính năng **Tự động gợi ý giai điệu theo thể loại truyện (Genre-Aware Recommendation)** cùng thanh điều khiển nổi thu gọn (`FloatingMiniPlayer`).
- **Tính năng AI Đột phá (FR-11 & FR-12):**
  - **Tìm kiếm bằng Hình ảnh AI (Visual Search - FR-11):** Chọn ảnh bìa/khung tranh qua Android Photo Picker (Zero Storage Permission - `NFR-12`) để nhận diện tác phẩm tức thì.
  - **Dịch thuật Khung thoại AI (AI Translate Overlay - FR-12):** Nút `✨ Dịch AI` ngay trên màn hình đọc giúp quét OCR và phủ bản dịch Tiếng Việt trực tiếp lên trang truyện ngoại ngữ.
- **Kiến trúc Offline-First & Đa tài khoản (FR-00, FR-06, FR-07, FR-08):** Quản lý tài khoản (Đăng nhập, Đăng ký, Quên mật khẩu, Chế độ Khách), Tủ sách cá nhân (Yêu thích, Đã tải ngoại tuyến, Lịch sử đọc dở) cục bộ qua **SQLite v3 (6 bảng chuẩn hóa 3NF)**, tải chương đa luồng (4 trang song song) kèm thanh tiến trình thời gian thực và cơ chế tự động dọn dẹp (Atomic Rollback) khi lỗi mạng.
- **Giao diện Linh hoạt AMOLED Dark & Light Mode (FR-14, NFR-16):** Chuyển đổi tức thì giữa chế độ Đen sâu AMOLED (`#111116`) tiết kiệm pin màn hình OLED và chế độ Sáng (Light Mode) dịu mắt.

---

## 2. Kiến trúc phần mềm (Clean Architecture)

Naomi tuân thủ nghiêm ngặt mô hình **Clean Architecture 3 tầng** kết hợp với **BLoC (Business Logic Component)** và **GetIt Service Locator**:

```text
               ┌────────────────────────────────────────────────────────────┐
               │                     PRESENTATION LAYER                     │
               │  • Screens (Auth, Discover, Detail, Reader, Library, ...)  │
               │  • BLoCs (AuthBloc, DiscoverBloc, ComicDetailBloc,         │
               │           ReaderBloc, LibraryBloc) + ThemeController       │
               │  • Widgets (ComicCard, AmbientAudioSheet, MiniPlayer, ...) │
               └─────────────────────────────┬──────────────────────────────┘
                                             │ Calls
                                             ▼
               ┌────────────────────────────────────────────────────────────┐
               │                        DOMAIN LAYER                        │
               │  • Entities (UserEntity, Comic, Chapter, ChapterPages,     │
               │              Bookmark, DownloadedChapter, ReadingHistory)  │
               │  • UseCases (GetTrending, Search, DownloadChapter, ...)    │
               │  • Repositories (Interfaces: Auth, Comic, Reader, Library) │
               └─────────────────────────────▲──────────────────────────────┘
                                             │ Implements
                                             │
               ┌─────────────────────────────┴──────────────────────────────┐
               │                         DATA LAYER                         │
               │  • Repositories Impl (Auth, Comic, Reader, Library)        │
               │  • Data Sources:                                           │
               │    - Remote: MangaDex REST API v5 (Auto-Retry & Backoff)   │
               │    - Local: SQLite v3 (6 bảng + 4 B-Tree Indexes)          │
               │  • Models: JSON Deserialization & Relational Mappers       │
               └────────────────────────────────────────────────────────────┘
```

---

## 3. Ma trận đối chiếu yêu cầu (Requirements Traceability Matrix)

### 3.1. Yêu cầu Chức năng (Functional Requirements: FR-00 $\rightarrow$ FR-15)
| Mã YC | Mô tả chức năng | Vị trí hiện thực trong Mã nguồn (Source Code) | Trạng thái |
| :--- | :--- | :--- | :---: |
| **FR-00** | Đăng nhập, Đăng ký, Quên mật khẩu & Chế độ Khách | `lib/features/auth/presentation/screens/login_screen.dart`<br>`lib/features/auth/presentation/bloc/auth_bloc.dart` | ✅ Hoàn thành |
| **FR-01** | Tìm kiếm truyện theo từ khóa, thể loại & Cuộn vô tận | `lib/features/comic/presentation/bloc/discover/discover_bloc.dart`<br>`lib/features/comic/presentation/screens/discover_screen.dart` | ✅ Hoàn thành |
| **FR-02** | Chế độ đọc tập trung (Focus Mode ẩn/hiện thanh UI) | `lib/features/reader/presentation/screens/reader_screen.dart`<br>`lib/features/reader/presentation/bloc/reader_bloc.dart` | ✅ Hoàn thành |
| **FR-03** | Chuyển đổi linh hoạt Webtoon dọc / Manga ngang | `lib/features/reader/presentation/screens/reader_screen.dart` | ✅ Hoàn thành |
| **FR-04** | Tự động lưu & khôi phục chính xác trang/vị trí đọc dở | `lib/features/reader/domain/usecases/save_reading_progress.dart`<br>`lib/features/reader/presentation/screens/reader_screen.dart` | ✅ Hoàn thành |
| **FR-05** | Phát nhạc nền Ambient & tự động gợi ý theo thể loại | `lib/core/audio/ambient_audio_service.dart`<br>`lib/features/reader/presentation/widgets/ambient_audio_sheet.dart` | ✅ Hoàn thành |
| **FR-06** | Tải chương đa luồng đọc Offline kèm tiến trình `%` | `lib/features/library/data/datasources/library_local_data_source.dart`<br>`lib/features/comic/presentation/screens/comic_detail_screen.dart` | ✅ Hoàn thành |
| **FR-07** | Quản lý Tủ sách Yêu thích cá nhân (Bookmarks) | `lib/features/library/domain/usecases/toggle_bookmark.dart`<br>`lib/features/library/presentation/screens/library_screen.dart` | ✅ Hoàn thành |
| **FR-08** | Quản lý Lịch sử đọc & Tiếp tục đọc nhanh một chạm | `lib/features/library/presentation/screens/library_screen.dart`<br>`lib/features/comic/presentation/screens/discover_screen.dart` | ✅ Hoàn thành |
| **FR-10** | Khám phá truyện Thịnh hành & Lọc theo Thể loại | `lib/features/comic/data/datasources/mangadex_remote_data_source.dart` | ✅ Hoàn thành |
| **FR-11** | Tìm kiếm truyện bằng hình ảnh AI (Visual Search) | `lib/features/comic/presentation/screens/discover_screen.dart` | ✅ Hoàn thành |
| **FR-12** | Dịch thuật khung thoại trực tiếp bằng AI (AI Translate) | `lib/features/reader/presentation/screens/reader_screen.dart` | ✅ Hoàn thành |
| **FR-13** | Phân trang đầy đủ danh sách chương & khử trùng lặp | `lib/features/comic/data/datasources/mangadex_remote_data_source.dart`<br>`lib/features/comic/presentation/screens/comic_detail_screen.dart` | ✅ Hoàn thành |
| **FR-14** | Tuỳ chỉnh Giao diện Sáng/Tối AMOLED & Ngôn ngữ dịch | `lib/core/theme/theme_controller.dart`<br>`lib/features/profile/presentation/screens/profile_screen.dart` | ✅ Hoàn thành |
| **FR-15** | Quản lý & Dọn dẹp bộ nhớ đệm (Cache Management) | `lib/features/profile/presentation/screens/profile_screen.dart` | ✅ Hoàn thành |

### 3.2. Yêu cầu Phi chức năng (Non-Functional Requirements)
| Mã YC | Tiêu chuẩn kỹ thuật | Hiện thực trong Naomi |
| :--- | :--- | :--- |
| **NFR-01/02** | Cuộn trang 60 FPS, tải trước ảnh không giật lag | Thiết lập `cacheExtent: 2500` trên Webtoon `ListView.builder` và tách `InteractiveViewer` ra ngoài danh sách |
| **NFR-07** | Bộ nhớ đệm tạm thời giới hạn tối đa 500MB | Quản lý Cache trong `profile_screen.dart` với thanh dung lượng trực quan và nút dọn dẹp 1 chạm |
| **NFR-08** | Chịu lỗi mạng & Rate-Limit (HTTP 429 / 5xx) | Interceptor tự động Retry với Exponential Backoff trong `lib/core/network/dio_client.dart` |
| **NFR-09** | Tốc độ phản hồi CSDL cục bộ $\le$ 50ms | Thiết lập 4 chỉ mục B-Tree Index trên 6 bảng SQLite v3 trong `lib/core/database/database_helper.dart` |
| **NFR-10/11** | Bảo mật Token AES-256 & Chặn Cleartext HTTP | Tích hợp `flutter_secure_storage` và cấu hình `android:usesCleartextTraffic="false"` trong `AndroidManifest.xml` |
| **NFR-12** | Zero Storage Permission (Quyền riêng tư tối đa) | Lưu trữ vào Application Sandbox (`getApplicationDocumentsDirectory`) và dùng System Photo Picker |
| **NFR-16** | Chế độ tối AMOLED tiết kiệm pin màn OLED | Định nghĩa bảng màu AMOLED (`#111116`) tại `app_colors.dart`, điều khiển thời gian thực qua `ThemeController` |
| **NFR-17** | Xử lý ngắt âm thanh hệ thống (Audio Focus) | Tích hợp `audio_session` tự động hạ âm lượng (ducking) hoặc tạm dừng khi có cuộc gọi đến |

---

## 4. Nhật ký Thay đổi Kiến trúc & Thiết kế (Architecture & Design Change Log)

So với bản Đặc tả Yêu cầu & Thiết kế ban đầu ở **Assignment 01**, quá trình hiện thực hóa và kiểm toán kỹ thuật ở **Assignment 02** đã thực hiện các nâng cấp và điều chỉnh kiến trúc có chủ đích sau:

1. **Bổ sung `ThemeController` toàn cục kết hợp BLoC (`lib/core/theme/theme_controller.dart`):**
   - *Lý do:* Đặc tả Assignment 01 tập trung vào các BLoC theo từng phân hệ (`DiscoverBloc`, `ReaderBloc`, `LibraryBloc`). Trong thực tế triển khai, việc chuyển đổi tức thì giữa `AMOLED Dark Mode` và `Light Mode` (`FR-14`), lưu ngôn ngữ bản dịch ưu tiên (`vi`/`en`/`all`), và điều hướng liên màn hình từ màn hình Lỗi mất mạng sang thẳng tab *"Đã Tải"* của Tủ sách (`S09` $\rightarrow$ `S07`) cần một bộ điều phối nhẹ toàn cục. `ThemeController` (`ChangeNotifier` đăng ký Singleton trong `GetIt`) giải quyết triệt để bài toán này mà không tạo sự phụ thuộc chéo giữa các BLoC.
2. **Nâng cấp Lược đồ Cơ sở dữ liệu SQLite lên Phiên bản 3 (`_dbVersion = 3` tại `database_helper.dart`):**
   - *Lý do:* Để hỗ trợ phân tách dữ liệu rạch ròi giữa các tài khoản đăng nhập và tài khoản Khách (`FR-00`), bảng `offline_downloads` được bổ sung cột `user_id` cùng cơ chế tự động nâng cấp (`onUpgrade` từ v1/v2 lên v3 không làm mất dữ liệu cũ). Đồng thời, quá trình tải chương (`library_local_data_source.dart`) thực hiện `UPSERT` đồng bộ vào cả 3 bảng quan hệ `comics`, `chapters` và `offline_downloads` để đảm bảo toàn vẹn khóa ngoại (3NF).
3. **Tối ưu Hóa Kiến trúc Cuộn Webtoon & Cử chỉ Đa điểm (`reader_screen.dart`):**
   - *Lý do:* Ở thiết kế sơ bộ, việc đặt `InteractiveViewer` bên trong từng phần tử của `ListView.builder` gây tranh chấp cử chỉ vuốt dọc (Gesture Arena conflict) và làm giảm tốc độ khung hình. Kiến trúc mới đưa `InteractiveViewer` ra bao bọc bên ngoài `ListView.builder`, kết hợp `NotificationListener<ScrollNotification>` để tính toán chính xác trang hiện tại dựa trên tỷ lệ cuộn và khôi phục đúng vị trí pixel khi mở lại chương đang đọc dở.
4. **Cơ chế Phân trang Tuần hoàn & Khử trùng lặp Chương cho MangaDex API v5 (`mangadex_remote_data_source.dart`):**
   - *Lý do:* Endpoint `/manga/{id}/feed` của MangaDex giới hạn tối đa 500 bản ghi mỗi lần gọi và trả về nhiều bản dịch của các nhóm dịch (scanlation groups) khác nhau cho cùng một số chương. Tầng Data Source đã được nâng cấp với vòng lặp phân trang (`offset += 500`, tải tối đa 2.500 bản ghi) và tầng Presentation áp dụng thuật toán khử trùng lặp theo `chapterNumber` (ưu tiên giữ lại bản dịch Tiếng Việt `vi`), giúp những bộ truyện dài kỳ như *One Piece*, *Detective Conan*, *Martial Peak* hiển thị đầy đủ 100% số chương.
5. **Tải Ngoại tuyến Đa luồng theo Lô (Concurrent Batch Download) & Atomic Rollback (`library_local_data_source.dart`):**
   - *Lý do:* Thay vì tải tuần tự từng ảnh gây chậm trễ, hệ thống chia danh sách trang thành các lô 4 trang tải song song (`Future.wait`), phát sự kiện tiến trình `onProgress(downloaded, total)` lên giao diện theo thời gian thực (`S11`). Nếu bất kỳ trang nào lỗi sau khi đã retry, cơ chế Atomic Rollback sẽ tự động xóa thư mục dở dang để tránh rác bộ nhớ (`NFR-12`).

---

## 5. Báo cáo Kiểm thử Chấp thuận & Đối chiếu Gherkin BDD (Acceptance Testing & Verification Report)

Toàn bộ các kịch bản Gherkin BDD trong đặc tả Assignment 01 (`US-00` đến `US-08`) và 12 màn hình (`S01` đến `S12`) đã được kiểm chứng thực tế:

| Mã User Story | Kịch bản Chấp thuận (Gherkin BDD Scenarios) | Phương pháp Kiểm chứng | Kết quả |
| :--- | :--- | :--- | :---: |
| **US-00** | Đăng ký tài khoản mới, Đăng nhập, Khôi phục mật khẩu ("Quên mật khẩu?") và Chế độ Khách (Guest Mode) | Kiểm thử tự động trong `test/features/auth/auth_bloc_test.dart` (4/4 kịch bản) & Kiểm thử UI tại `S01`, `S02` | **PASSED (100%)** |
| **US-01** | Tìm kiếm truyện theo từ khóa, lọc theo thể loại, cuộn vô tận (Infinite Scroll) & Tìm kiếm bằng ảnh AI (`FR-11`) | Kiểm thử tự động trong `test/features/comic/discover_bloc_test.dart` & Kiểm thử UI tại `S03` | **PASSED (100%)** |
| **US-02** | Chuyển đổi mượt mà giữa chế độ cuộn dọc Webtoon và lật ngang Manga, chạm giữa màn hình bật/tắt Focus Mode | Kiểm thử tự động trong `test/features/reader/reader_bloc_test.dart` & Kiểm thử UI tại `S05`, `S06` | **PASSED (100%)** |
| **US-03** | Phát nhạc nền Ambient theo thể loại truyện, tự động gợi ý bài nhạc phù hợp, thu gọn về `FloatingMiniPlayer` và tắt hẳn bằng nút `X` | Kiểm thử UI & Audio Session tại `S06`, `S08` và thanh Mini Player toàn cục | **PASSED (100%)** |
| **US-04** | Tự động lưu trang đang đọc dở ở cả chế độ Manga lẫn Webtoon, hiển thị thẻ *"Đọc tiếp"* ở Trang chủ và khôi phục đúng vị trí khi mở lại | Kiểm thử tích hợp SQLite `reading_history` tại `S03`, `S05`, `S07` | **PASSED (100%)** |
| **US-05** | Tải chương truyện về máy với thanh tiến trình `%` thời gian thực (`S11`), đọc 100% Offline khi ngắt mạng và tự động dọn dẹp nếu hủy/lỗi | Kiểm thử tự động trong `test/features/library/library_bloc_test.dart` & Kiểm thử Offline tại `S04`, `S07`, `S09`, `S11` | **PASSED (100%)** |
| **US-06** | Thêm/xóa truyện khỏi danh sách Yêu thích (Bookmarks), đồng bộ tức thì với Tủ sách cá nhân | Kiểm thử tự động trong `test/features/library/library_bloc_test.dart` & Kiểm thử UI tại `S04`, `S07` | **PASSED (100%)** |
| **US-07** | Dịch thuật khung thoại ngoại ngữ trực tiếp trên trang truyện bằng lớp phủ AI (`✨ Dịch AI`) | Kiểm thử UI tại màn hình đọc `S05`, `S06` | **PASSED (100%)** |
| **US-08** | Chuyển đổi giao diện Sáng / Tối AMOLED thời gian thực, chọn ngôn ngữ dịch mặc định và dọn dẹp bộ nhớ đệm Cache | Kiểm thử UI tại màn hình Hồ sơ `S12` (`ProfileScreen`) | **PASSED (100%)** |

### Kết quả Chạy Kiểm thử Tự động (Unit & Widget Tests)
- **Phân tích tĩnh (`flutter analyze`):** `No issues found!` (0 lỗi, 0 cảnh báo).
- **Kiểm thử đơn vị & giao diện (`flutter test`):** **18/18 tests PASSED (100%)** bao phủ:
  - `test/features/auth/auth_bloc_test.dart` (4 tests)
  - `test/features/comic/discover_bloc_test.dart` (4 tests)
  - `test/features/reader/reader_bloc_test.dart` (4 tests)
  - `test/features/library/library_bloc_test.dart` (3 tests)
  - `test/widget_test.dart` (3 tests)

---

## 6. Hướng dẫn Cài đặt & Khởi chạy (Getting Started)

### 6.1. Yêu cầu môi trường
- Flutter SDK $\ge 3.16.0$ (Đã kiểm chứng trên Flutter 3.47+ / Dart 3.0+)
- Android Studio / VS Code cài đặt Flutter & Dart Extension
- Thiết bị Android thật / Máy ảo Android (API 21+) hoặc Windows Desktop

### 6.2. Cài đặt thư viện
Tại thư mục gốc của dự án, mở Terminal và di chuyển vào thư mục ứng dụng `Naomi`:
```bash
cd Naomi
flutter pub get
```

### 6.3. Kiểm tra phân tích mã nguồn & Chạy toàn bộ Test Suite (18/18 tests Passed)
```bash
flutter analyze
flutter test
```

### 6.4. Chạy ứng dụng trực tiếp
```bash
flutter run
```

### 6.5. Biên dịch bản cài đặt Release
- **Biên dịch Android Release APK:**
  ```bash
  flutter build apk --release
  ```
  *File APK xuất ra tại: `Naomi/build/app/outputs/flutter-apk/app-release.apk`*

- **Biên dịch Windows Release Native:**
  ```bash
  flutter build windows --release
  ```
  *File thực thi xuất ra tại: `Naomi/build/windows/x64/runner/Release/naomi.exe`*

---

## 7. Cấu trúc thư mục dự án (Project Directory Structure)

```text
Naomi/
├── android/                   # Cấu hình Native Android & Quyền Bảo mật Manifest (NFR-11/12)
├── lib/
│   ├── core/                  # Hạ tầng dùng chung (Core Infrastructure)
│   │   ├── audio/             # Trình phát nhạc nền Ambient & Gợi ý theo thể loại (FR-05, NFR-17)
│   │   ├── database/          # SQLite DatabaseHelper v3 & Schema 6 bảng + 4 Indexes (NFR-09)
│   │   ├── di/                # Dependency Injection Service Locator (GetIt)
│   │   ├── errors/            # Xử lý ngoại lệ Failures & Exceptions
│   │   ├── network/           # DioClient với Auto-Retry Exponential Backoff (NFR-08)
│   │   └── theme/             # AMOLED Dark / Light Theme & ThemeController (FR-14, NFR-16)
│   ├── features/
│   │   ├── auth/              # Đăng nhập, Đăng ký, Quên mật khẩu & Chế độ Khách (FR-00)
│   │   ├── comic/             # Khám phá, Cuộn vô tận, Visual Search AI & Chi tiết truyện
│   │   ├── reader/            # Động cơ đọc Webtoon/Manga, Focus Mode & AI Translate (FR-02..12)
│   │   ├── library/           # Tủ sách cá nhân & Tải ngoại tuyến đa luồng (FR-06, FR-07, FR-08)
│   │   ├── profile/           # Cài đặt giao diện, Ngôn ngữ & Dọn dẹp Cache (FR-14, FR-15)
│   │   └── home/              # Điều hướng chính & FloatingMiniPlayer
│   └── main.dart              # Điểm khởi chạy ứng dụng (Entry Point)
└── test/                      # Bộ Unit & Widget Tests toàn diện (18/18 kịch bản)
```

---

## 8. Giấy phép (License)
Dự án được xây dựng phục vụ mục đích nghiên cứu và đánh giá học phần Phát triển Ứng dụng Di động tại Trường Đại học Bách Khoa - ĐHQG TP.HCM.
