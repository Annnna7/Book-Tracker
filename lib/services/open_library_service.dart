import 'api_service.dart';
import '../models/Book.dart';

/// Сервис для работы с OpenLibrary API
class OpenLibraryService {
  static const String _baseUrl = 'https://openlibrary.org';

  /// Поиск книг в OpenLibrary
  static Future<ApiResponse<List<Book>>> searchBooks(String query) async {
    return ApiService.get(
      url: '$_baseUrl/search.json?q=${Uri.encodeQueryComponent(query)}&limit=20',
      parser: (data) => _parseSearchResults(data),
    );
  }

  /// Получение детальной информации о книге
  static Future<ApiResponse<Book>> fetchBookDetails(String bookKey) async {
    if (bookKey.isEmpty) {
      return ApiResponse.error(
        errorType: ApiErrorType.parsing,
        message: 'Неверный ключ книги',
      );
    }

    return ApiService.get(
      url: '$_baseUrl$bookKey.json',
      parser: (data) => _parseBookDetails(data),
    );
  }

  /// Парсинг результатов поиска
  /// Парсинг результатов поиска
  static List<Book> _parseSearchResults(Map<String, dynamic> data) {
    final List<dynamic> docs = data['docs'] ?? [];
    return docs
        .where((doc) => doc != null && doc is Map<String, dynamic>)
        .map<Book>((doc) => _parseBookFromSearchDoc(doc as Map<String, dynamic>))
        .where((book) => book.title != 'Без названия')
        .toList();
  }

  /// Парсинг книги из документа поиска
  static Book _parseBookFromSearchDoc(Map<String, dynamic> doc) {
    // Обработка авторов
    final dynamic authorNames = doc['author_name'];
    String authorText;
    if (authorNames is List && authorNames.isNotEmpty) {
      authorText = authorNames
          .where((a) => a != null)
          .map((a) => a.toString())
          .join(', ');
    } else {
      authorText = 'Автор неизвестен';
    }

    // Извлекаем жанр (первый subject)
    final dynamic subjects = doc['subject'];
    String? genre;
    if (subjects is List && subjects.isNotEmpty) {
      final firstSubject = subjects[0];
      if (firstSubject is String) {
        genre = firstSubject;
      }
    }

    // Извлекаем издательство
    final dynamic publishers = doc['publisher'];
    String? publisher;
    if (publishers is List && publishers.isNotEmpty) {
      final firstPublisher = publishers[0];
      if (firstPublisher is String) {
        publisher = firstPublisher;
      }
    }

    // Обработка даты первой публикации
    String? firstPublishDate;
    final publishDate = doc['first_publish_year'] ?? doc['publish_date']?[0];
    if (publishDate != null) {
      firstPublishDate = publishDate.toString();
    }

    final String bookKey = doc['key'] ?? '';

    return Book(
      title: doc['title']?.toString() ?? 'Без названия',
      author: authorText,
      coverUrl: doc['cover_i'] != null
          ? 'https://covers.openlibrary.org/b/id/${doc['cover_i']}-M.jpg'
          : null,
      key: bookKey,
      description: null, // Описание будет загружено отдельно
      genre: genre,
      publisher: publisher,
      totalPages: null, // Количество страниц будет загружено отдельно
      firstPublishDate: firstPublishDate,
      subjects: _parseStringList(doc['subject']),
      subjectPlaces: _parseStringList(doc['place']),
      subjectTimes: _parseStringList(doc['time']),
    );
  }

  /// Парсинг детальной информации о книге
  static Book _parseBookDetails(Map<String, dynamic> data) {
    // Обработка авторов
    String author = 'Неизвестный автор';
    if (data['authors'] != null && data['authors'].isNotEmpty) {
      final authorData = data['authors'][0];
      if (authorData['author'] is Map && authorData['author']['key'] != null) {
        author = _extractAuthorName(authorData['author']['key']);
      }
    }

    // Обработка обложки
    String? coverUrl;
    if (data['covers'] != null && data['covers'].isNotEmpty) {
      final coverId = data['covers'][0];
      coverUrl = 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';
    }

    // Обработка описания
    String? description;
    if (data['description'] != null) {
      if (data['description'] is String) {
        description = data['description'];
      } else if (data['description'] is Map && data['description']['value'] != null) {
        description = data['description']['value'];
      }
    }

    return Book(
      title: data['title']?.toString() ?? 'Без названия',
      author: author,
      coverUrl: coverUrl,
      description: description,
      genre: data['genres']?[0]?.toString(), // Используем genres из детальной информации
      publisher: _extractPublisher(data),
      totalPages: data['number_of_pages'] as int? ?? data['total_pages'] as int?,
      firstPublishDate: data['first_publish_date']?.toString(),
      subjects: _parseStringList(data['subjects']),
      subjectPlaces: _parseStringList(data['subject_places']),
      subjectTimes: _parseStringList(data['subject_times']),
      key: data['key']?.toString(),
    );
  }

  /// Вспомогательные методы для парсинга
  static String _extractAuthorName(String authorKey) {
    final parts = authorKey.split('/').last;
    return parts.replaceAll('_', ' ').replaceAll('OL', '');
  }

  static String? _extractPublisher(Map<String, dynamic> json) {
    if (json['publishers'] != null && json['publishers'].isNotEmpty) {
      return json['publishers'][0]?.toString();
    }
    return json['publisher']?.toString();
  }

  static List<String>? _parseStringList(dynamic data) {
    if (data is List) {
      return data
          .where((item) => item != null)
          .map((item) => item.toString())
          .toList();
    }
    return null;
  }
}