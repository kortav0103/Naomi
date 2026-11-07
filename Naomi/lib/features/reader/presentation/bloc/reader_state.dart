import 'package:equatable/equatable.dart';
import '../../domain/entities/chapter_pages.dart';

abstract class ReaderState extends Equatable {
  const ReaderState();

  @override
  List<Object?> get props => [];
}

class ReaderInitial extends ReaderState {}

class ReaderLoading extends ReaderState {}

class ReaderLoaded extends ReaderState {
  final ChapterPages pages;
  final int currentPage; // 1-based để hiển thị cho người đọc (vd: Trang 5/40)
  final String comicId;
  final String comicTitle;
  final String? coverUrl;
  final String chapterNumber;
  final bool isWebtoonMode; // true = cuộn dọc, false = lật trang ngang (FR-03)
  final bool isRTL; // true = Phải sang Trái (Chuẩn Manga Nhật), false = Trái sang Phải
  final bool isFocusMode; // true = ẩn thanh công cụ, chỉ hiển thị truyện (FR-02)
  final bool isDataSaver; // true = dùng ảnh nén 4G

  const ReaderLoaded({
    required this.pages,
    this.currentPage = 1,
    this.comicId = '',
    this.comicTitle = 'Manga',
    this.coverUrl,
    this.chapterNumber = '1',
    this.isWebtoonMode = true, // Mặc định cuộn dọc kiểu Webtoon
    this.isRTL = false, // Mặc định lật từ trái sang phải
    this.isFocusMode = false,
    this.isDataSaver = false,
  });

  ReaderLoaded copyWith({
    ChapterPages? pages,
    int? currentPage,
    String? comicId,
    String? comicTitle,
    String? coverUrl,
    String? chapterNumber,
    bool? isWebtoonMode,
    bool? isRTL,
    bool? isFocusMode,
    bool? isDataSaver,
  }) {
    return ReaderLoaded(
      pages: pages ?? this.pages,
      currentPage: currentPage ?? this.currentPage,
      comicId: comicId ?? this.comicId,
      comicTitle: comicTitle ?? this.comicTitle,
      coverUrl: coverUrl ?? this.coverUrl,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      isWebtoonMode: isWebtoonMode ?? this.isWebtoonMode,
      isRTL: isRTL ?? this.isRTL,
      isFocusMode: isFocusMode ?? this.isFocusMode,
      isDataSaver: isDataSaver ?? this.isDataSaver,
    );
  }

  @override
  List<Object?> get props => [
        pages,
        currentPage,
        comicId,
        comicTitle,
        coverUrl,
        chapterNumber,
        isWebtoonMode,
        isRTL,
        isFocusMode,
        isDataSaver,
      ];
}

class ReaderError extends ReaderState {
  final String message;
  const ReaderError(this.message);

  @override
  List<Object?> get props => [message];
}
