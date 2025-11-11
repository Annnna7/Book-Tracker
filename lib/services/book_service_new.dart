import 'open_library_service.dart';
import 'google_books_service.dart';
import '../models/Book.dart';

/// Унифицированный сервис для работы с книгами из разных источников
class BookService {
  final GoogleBooksService? googleBooksService;

  BookService({this.googleBooksService});

  /// Поиск книг во всех доступных источниках
  Future<BookSearchResult> searchBooks(String query) async {
    final List<Book> allBooks = [];
    final List<String> errors = [];

    // Поиск в OpenLibrary
    final openLibraryResult = await OpenLibraryService.searchBooks(query);
    if (openLibraryResult.success) {
      allBooks.addAll(openLibraryResult.data!);
    } else {
      errors.add('OpenLibrary: ${openLibraryResult.message}');
    }

    // Поиск в Google Books (если доступен)
    if (googleBooksService != null) {
      final googleResult = await googleBooksService!.searchBooks(query);
      if (googleResult.success) {
        allBooks.addAll(googleResult.data!);
      } else {
        errors.add('Google Books: ${googleResult.message}');
      }
    }

    return BookSearchResult(
      books: allBooks,
      errors: errors,
      hasErrors: errors.isNotEmpty,
    );
  }

  /// Получение детальной информации о книге
  Future<Book> getBookDetails(Book book) async {
    // Если книга из OpenLibrary и у нее есть ключ
    if (book.key != null && book.key!.startsWith('/works/')) {
      final result = await OpenLibraryService.fetchBookDetails(book.key!);
      if (result.success) {
        return result.data!;
      }
    }

    // Если книга из Google Books и у нее есть ключ
    if (googleBooksService != null && book.key != null && !book.key!.startsWith('/works/')) {
      final result = await googleBooksService!.fetchBookDetails(book.key!);
      if (result.success) {
        return result.data!;
      }
    }

    // Если не удалось получить детали, возвращаем исходную книгу
    return book;
  }

  /// Обогащение книги детальной информацией (если нужно дополнить существующие данные)
  Future<Book> enrichBookDetails(Book book) async {
    final detailedBook = await getBookDetails(book);

    // Используем copyWith чтобы сохранить данные, которых нет в детальной информации
    return book.copyWith(
      description: detailedBook.description ?? book.description,
      totalPages: detailedBook.totalPages ?? book.totalPages,
      genre: detailedBook.genre ?? book.genre,
      publisher: detailedBook.publisher ?? book.publisher,
      firstPublishDate: detailedBook.firstPublishDate ?? book.firstPublishDate,
      subjects: detailedBook.subjects ?? book.subjects,
      subjectPlaces: detailedBook.subjectPlaces ?? book.subjectPlaces,
      subjectTimes: detailedBook.subjectTimes ?? book.subjectTimes,
    );
  }
}

/// Результат поиска книг
class BookSearchResult {
  final List<Book> books;
  final List<String> errors;
  final bool hasErrors;

  BookSearchResult({
    required this.books,
    required this.errors,
    required this.hasErrors,
  });
}