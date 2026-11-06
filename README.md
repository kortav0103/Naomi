# Naomi
# NAOMI — Ambient Manga Reader & Tracker

> **Đồ án môn học:** Phát triển Ứng dụng Di động (Mobile Development Course Project)  
> **Trường:** Đại học Bách Khoa - ĐHQG TP.HCM (HCMUT - VNU-HCM)  
> **Giảng viên hướng dẫn:** TS. Phan Trần Minh Khuê  
> **Sinh viên thực hiện:** Nguyễn Tuấn Kiệt — MSSV: 2211765  
> **Phiên bản:** `v1.0.0-release` (Assignment 02 Implementation)

---

## 1. Giới thiệu tổng quan (Overview)

**Naomi** là ứng dụng đọc và theo dõi truyện tranh di động được thiết kế theo triết lý **Tối giản (Minimalism) & Đắm chìm (Ambient Reading)**:
- **Tối ưu trải nghiệm đọc:** Hỗ trợ linh hoạt cả 2 chế độ đọc phổ biến: **Webtoon (Cuộn dọc liên tục)** và **Manga (Lật ngang từng trang với Zoom tương tác `InteractiveViewer`)**.
- **Chế độ đọc tập trung (Focus Mode - FR-02):** Tự động ẩn toàn bộ thanh công cụ, thanh trạng thái để trả lại 100% không gian hiển thị cho từng khung tranh.
- **Không gian âm thanh thư giãn (Ambient Soundscapes - FR-05):** Tích hợp trình phát nhạc nền không lời với các chủ đề đa dạng (Lo-Fi Chill, Rainy Lofi, Piano Solo, Tokyo Night Vibes) giúp người đọc thư giãn tối đa.
- **Kiến trúc Offline-First (FR-06 & FR-07):** Quản lý Tủ sách cá nhân (Yêu thích, Tải ngoại tuyến, Lịch sử đọc dở) cục bộ qua SQLite, hỗ trợ đọc truyện mượt mà kể cả khi không có kết nối Internet.
- **Giao diện AMOLED Dark (NFR-16):** Thiết kế bảng màu đen sâu (`#111116`) kết hợp sắc tím dịu (`#7066A6`), tối ưu hóa tuổi thọ pin trên màn hình OLED và bảo vệ thị lực ban đêm.

---

## 2. Kiến trúc phần mềm (Clean Architecture)

Naomi tuân thủ nghiêm ngặt mô hình **Clean Architecture 3 tầng** kết hợp với **BLoC (Business Logic Component)** để quản lý trạng thái dự đoán được (predictable state):

```text
               ┌────────────────────────────────────────────────────────┐
               │                  PRESENTATION LAYER                    │
               │  • Screens (Discover, Detail, Reader, Library, Profile)│
               │  • BLoCs (DiscoverBloc, ReaderBloc, LibraryBloc)       │
               │  • Widgets (ComicCard, AmbientAudioSheet, ...)         │
               └───────────────────────────┬────────────────────────────┘
                                           │ Calls
                                           ▼
               ┌────────────────────────────────────────────────────────┐
               │                     DOMAIN LAYER                       │
               │  • Entities (Comic, Chapter, ChapterPages, Bookmark)   │
               │  • UseCases (GetTrending, Search, SaveProgress, ...)   │
               │  • Repositories (Interfaces: ComicRepository, ...)     │
               └───────────────────────────▲────────────────────────────┘
                                           │ Implements
                                           │
               ┌───────────────────────────┴────────────────────────────┐
               │                      DATA LAYER                        │
               │  • Repositories Impl (ComicRepositoryImpl, ...)        │
               │  • Data Sources:                                       │
               │    - Remote: MangaDex REST API v5                      │
               │    - Local: SQLite DatabaseHelper & Documents Cache    │
               │  • Models: JSON Deserialization & Data Mappers         │
               └────────────────────────────────────────────────────────┘
```

---

## 3. Ma trận đối chiếu yêu cầu (Requirements Traceability Matrix)

### 3.1. Yêu cầu Chức năng (Functional Requirements - FR)
| Mã yêu cầu | Mô tả chức năng | Vị trí hiện thực trong Mã nguồn (Source Code) |
| :--- | :--- | :--- |
| **FR-01** | Tìm kiếm truyện tranh theo tên và tác giả | `lib/features/comic/domain/usecases/search_comics.dart`<br>`lib/features/comic/presentation/screens/discover_screen.dart` |
| **FR-02** | Chế độ đọc tập trung (Focus Mode ẩn UI) | `lib/features/reader/presentation/screens/reader_screen.dart`<br>`lib/features/reader/presentation/bloc/reader_bloc.dart` |
| **FR-03** | Chuyển đổi linh hoạt Webtoon dọc / Manga ngang | `lib/features/reader/presentation/screens/reader_screen.dart`<br>`lib/features/reader/presentation/bloc/reader_event.dart` |
| **FR-04** | Tự động lưu và đồng bộ vị trí đọc dở | `lib/features/reader/domain/usecases/save_reading_progress.dart`<br>`lib/features/reader/data/datasources/reader_local_data_source.dart` |
| **FR-05** | Phát nhạc nền không lời theo thể loại truyện (Ambient) | `lib/core/audio/ambient_audio_service.dart`<br>`lib/features/reader/presentation/widgets/ambient_audio_sheet.dart` |
| **FR-06** | Tải chương truyện về thiết bị để đọc ngoại tuyến | `lib/features/library/domain/usecases/download_chapter.dart`<br>`lib/features/library/data/datasources/library_local_data_source.dart` |
| **FR-07** | Quản lý Tủ sách yêu thích cá nhân (Bookmarks) | `lib/features/library/domain/usecases/toggle_bookmark.dart`<br>`lib/features/library/presentation/screens/library_screen.dart` |

### 3.2. Yêu cầu Phi chức năng (Non-Functional Requirements - NFR)
| Mã yêu cầu | Tiêu chuẩn kỹ thuật | Hiện thực trong Naomi |
| :--- | :--- | :--- |
| **NFR-07** | Bộ nhớ đệm tạm thời giới hạn tối đa 500MB | Quản lý Cache trong `profile_screen.dart` với thanh dung lượng và nút xóa cache một chạm |
| **NFR-09** | Tốc độ phản hồi CSDL cục bộ $\le$ 50ms | Thiết lập 4 chỉ mục B-Tree Index trên các bảng SQLite trong `database_helper.dart` |
| **NFR-10** | Bảo mật thông tin xác thực với AES-256 | Tích hợp thư viện `flutter_secure_storage` trong `injection_container.dart` |
| **NFR-16** | Chế độ tối AMOLED tiết kiệm pin màn OLED | Định nghĩa bảng màu AMOLED (`#111116`) tại `app_colors.dart` và `app_theme.dart` |
| **NFR-17** | Xử lý ngắt âm thanh hệ thống (Audio Focus) | Tích hợp `audio_session` cấu hình ưu tiên nhạc nền và tự hạ âm lượng khi có cuộc gọi |

---

## 4. Công nghệ & Thư viện sử dụng (Tech Stack)

- **Framework:** Flutter SDK `^3.13.7` (Tương thích hoàn toàn Flutter 3.47+)
- **Ngôn ngữ:** Dart `^3.0.0`
- **Quản lý trạng thái (State Management):** `flutter_bloc: ^8.1.6`, `equatable: ^2.0.7`
- **Bộ định vị phụ thuộc (Dependency Injection):** `get_it: ^8.0.3`
- **Mạng & API (Networking):** `dio: ^5.8.0+1`, `connectivity_plus: ^6.1.3`, `cached_network_image: ^3.4.1`
- **Lưu trữ CSDL cục bộ (Local Persistence):** `sqflite: ^2.4.1`, `path_provider: ^2.1.5`
- **Bảo mật (Security):** `flutter_secure_storage: ^9.2.4`, `supabase_flutter: ^2.8.4`
- **Âm thanh nền (Ambient Audio):** `just_audio: ^0.9.46`, `audio_session: ^0.1.25`

---

## 5. Hướng dẫn Cài đặt & Khởi chạy (Getting Started)

### 5.1. Yêu cầu môi trường
- Flutter SDK $\ge 3.16.0$
- Dart SDK $\ge 3.0.0$
- Android Studio / VS Code có cài đặt Flutter & Dart Extension
- Android SDK (API 21+) hoặc Visual Studio Community 2022 (nếu chạy bản Windows desktop)

### 5.2. Cài đặt thư viện
Tại thư mục gốc của dự án, mở Terminal và di chuyển vào thư mục ứng dụng `Naomi`:
```bash
cd Naomi
flutter pub get
```

### 5.3. Chạy toàn bộ Test Suite (14/14 tests Passed)
Kiểm tra tính toàn vẹn của mã nguồn và các BLoC:
```bash
flutter analyze
flutter test
```

### 5.4. Chạy ứng dụng trên máy ảo hoặc thiết bị thật
```bash
flutter run
```

### 5.5. Biên dịch bản cài đặt Release
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

## 6. Cấu trúc thư mục dự án (Project Directory Structure)

```text
Naomi/
├── android/                   # Cấu hình Native Android & Quyền Manifest
├── lib/
│   ├── core/                  # Hạ tầng dùng chung (Core Infrastructure)
│   │   ├── audio/             # Trình phát nhạc nền Ambient (FR-05, NFR-17)
│   │   ├── database/          # SQLite DatabaseHelper & Schema 6 bảng (NFR-09)
│   │   ├── di/                # Dependency Injection Service Locator (GetIt)
│   │   ├── errors/            # Xử lý ngoại lệ Failures & Exceptions
│   │   ├── network/           # DioClient với MangaDex User-Agent & Timeouts
│   │   └── theme/             # AMOLED Dark Theme & AppColors (NFR-16)
│   ├── features/
│   │   ├── comic/             # Phân hệ Khám phá & Chi tiết truyện (FR-01, FR-10)
│   │   ├── reader/            # Động cơ đọc truyện & Focus Mode (FR-02, FR-03, FR-04)
│   │   ├── library/           # Tủ sách cá nhân & Tải ngoại tuyến (FR-06, FR-07)
│   │   ├── profile/           # Cài đặt giao diện & Dọn dẹp Cache (NFR-07)
│   │   └── home/              # Thanh điều hướng chính (MainNavigationScreen)
│   └── main.dart              # Điểm khởi chạy ứng dụng (Entry Point)
└── test/                      # Bộ Unit Tests toàn diện cho BLoCs và Widgets
```

---

## 7. Giấy phép (License)
Dự án được xây dựng phục vụ mục đích nghiên cứu và đánh giá học phần Phát triển Ứng dụng Di động tại Trường Đại học Bách Khoa - ĐHQG TP.HCM.