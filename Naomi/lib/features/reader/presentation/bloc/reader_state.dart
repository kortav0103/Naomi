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
  final bool isWebtoonMode; // true = cuộn dọc, false = lật trang ngang (FR-03)
  final bool isFocusMode; // true = ẩn thanh công cụ, chỉ hiển thị truyện (FR-02)
  final bool isDataSaver; // true = dùng ảnh nén 4G

  const ReaderLoaded({
    required this.pages,
    this.currentPage = 1,
    this.isWebtoonMode = true, // Mặc định cuộn dọc kiểu Webtoon
    this.isFocusMode = false,
    this.isDataSaver = false,
  });

  ReaderLoaded copyWith({
    ChapterPages? pages,
    int? currentPage,
    bool? isWebtoonMode,
    bool? isFocusMode,
    bool? isDataSaver,
  }) {
    return ReaderLoaded(
      pages: pages ?? this.pages,
      currentPage: currentPage ?? this.currentPage,
      isWebtoonMode: isWebtoonMode ?? this.isWebtoonMode,
      isFocusMode: isFocusMode ?? this.isFocusMode,
      isDataSaver: isDataSaver ?? this.isDataSaver,
    );
  }

  @override
  List<Object?> get props => [pages, currentPage, isWebtoonMode, isFocusMode, isDataSaver];
}

class ReaderError extends ReaderState {
  final String message;
  const ReaderError(this.message);

  @override
  List<Object?> get props => [message];
}
